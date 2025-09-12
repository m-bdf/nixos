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

        let mut contents = String::new();
        let mut output = OutputHandle::FmtWrite(&mut contents);
        controller.print_file(&mut printer, &mut output, input, false, &None)?;
        input.reader.first_line = contents.as_bytes().to_vec();

        if !contents.contains("\x1b[") {
            for guess in guess_language_by_contents(&contents)? {
                if let Some(syntax) = self.find_syntax_by_token(&guess)? {
                    return Ok(Some(syntax));
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
