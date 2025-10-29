use crate::{
    controller::Controller,
    printer::SimplePrinter,
    output::OutputHandle,
};

impl HighlightingAssets {
    fn get_syntax_for_file_contents(
        &self,
        input: &mut OpenedInput,
    ) -> Result<Option<SyntaxReferenceInSet<'_>>> {
        let config = Default::default();
        let controller = Controller::new(&config, &self);
        let mut printer = SimplePrinter::new(&config);

        let mut contents = vec![];
        let mut output = OutputHandle::IoWrite(&mut contents);
        controller.print_file(&mut printer, &mut output, input, false, &None)?;
        input.reader.first_line = contents;

        if let Ok(contents) = str::from_utf8(&input.reader.first_line) {
            if !contents.contains("\x1b[") {
                if let Ok(guesses) = guess_language_by_contents(&contents) {
                    for guess in guesses {
                        if let Some(syntax) = self.find_syntax_by_token(&guess)? {
                            return Ok(Some(syntax));
                        }
                    }
                }
            }
        }
        Ok(None)
    }
}

fn guess_language_by_contents(contents: &str) -> Result<Vec<String>> {
    use rustyscript::{module, Module, RuntimeOptions, Runtime};

    const HIGHLIGHTJS: Module = module!("{HIGHLIGHTJS}");
    const MODULE: Module = module!("guess.js", "
        import hljs from '{HIGHLIGHTJS}';

        export default code => {
            try {
                JSON.parse(code);
                return [ 'json' ];
            } catch {}

            const result = hljs.highlightAuto(code);
            const first = hljs.getLanguage(result.language);
            const second = hljs.getLanguage(result.secondBest.language);
            return [
                first?.name ?? '', ...first?.aliases ?? [],
                second?.name ?? '', ...second?.aliases ?? [],
            ];
        };
    ");

    let options = RuntimeOptions {
        max_heap_size: Some(u32::MAX as usize),
        ..Default::default()
    };
    Runtime::execute_module(&MODULE, vec![&HIGHLIGHTJS], options, &contents)
        .map_err(|e| e.to_string().into())
}
