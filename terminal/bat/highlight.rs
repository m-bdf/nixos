type JsResult<T> = std::result::Result<T, rustyscript::Error>;

fn guess_language_by_contents(contents: &str) -> JsResult<[String; 2]> {
    eprintln!("Importing HighlightJS...");

    const GUESS_LANGUAGE_MODULE: rustyscript::Module =
        rustyscript::module!("guessLanguage", "
            import HighlightJS from 'https://esm.sh/highlight.js?standalone';
            export const guessLanguage = code => {
                const result = HighlightJS.highlightAuto(code);
                return [ result.language, result.secondBest.language ];
            };
        ");

    rustyscript::ModuleWrapper::new_from_module(&GUESS_LANGUAGE_MODULE, Default::default())?
        .call("guessLanguage", &contents)
}

impl HighlightingAssets {
    fn get_syntax_for_file_contents(
        &self,
        reader: &mut InputReader,
    ) -> Result<Option<SyntaxReferenceInSet<'_>>> {
        let config = Default::default();
        let controller = crate::controller::Controller::new(&config, &self);
        let mut printer = crate::printer::SimplePrinter::new(&config);

        let mut contents = String::new();
        let mut output = crate::output::OutputHandle::FmtWrite(&mut contents);
        controller.print_file_ranges(&mut printer, &mut output, reader, &Default::default())?;
        reader.first_line = contents.as_bytes().to_vec();

        for guess in guess_language_by_contents(&contents).map_err(|e| e.to_string())? {
            if let Some(syntax) = self.find_syntax_by_token(&guess)? {
                return Ok(Some(syntax));
            }
        }
        Ok(None)
    }
}
