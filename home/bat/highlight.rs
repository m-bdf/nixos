use std::process::{Command, Stdio, ChildStdin};

impl HighlightingAssets {
    fn get_syntax_for_file_contents(
        &self,
        reader: &mut InputReader,
    ) -> Result<Option<SyntaxReferenceInSet<'_>>> {
        if reader.first_line.is_empty()
        || reader.first_line.iter().any(u8::is_ascii_control) {
            return Ok(None);
        }

        let mut child = Command::new("{LANGUESS}")
            .stdin(Stdio::piped())
            .stdout(Stdio::piped())
            .stderr(Stdio::piped())
            .spawn()?;

        self.print_file_to_process(reader, &mut child.stdin.take().unwrap())?;
        
        let output = child.wait_with_output()?;
        *reader = InputReader::new(std::io::Cursor::new(output.stdout));

        for guess in String::from_utf8_lossy(&output.stderr).split_whitespace() {
            if let Some(syntax) = self.find_syntax_by_token(&guess)? {
                return Ok(Some(syntax));
            }
        }

        Ok(None)
    }

    fn print_file_to_process(
        &self,
        reader: &mut InputReader,
        stdin: &mut ChildStdin,
    ) -> Result<()> {
        use crate::{
            controller::Controller,
            printer::SimplePrinter,
            output::OutputHandle,
        };

        let config = Default::default();
        let controller = Controller::new(&config, &self);
        let mut printer = SimplePrinter::new(&config);
        let mut output = OutputHandle::IoWrite(stdin);
        let ranges = Default::default();

        controller.print_file_ranges(&mut printer, &mut output, reader, &ranges)
    }
}
