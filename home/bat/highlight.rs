impl HighlightingAssets {
    fn get_contents_syntax(
        &self,
        reader: &mut InputReader,
    ) -> Result<Option<SyntaxReferenceInSet<'_>>> {
        if reader.first_line.is_empty()
        || reader.first_line.contains(&b'\x1B') {
            return Ok(None);
        }

        if let Some(syntax) = self.get_first_line_syntax(reader)? {
            return Ok(Some(syntax));
        }

        let Ok(guesses) = guess_syntax_by_contents(reader) else {
            return Ok(None);
        };

        for guess in guesses.split_whitespace() {
            if let Some(syntax) = self.find_syntax_by_token(&guess)? {
                return Ok(Some(syntax));
            }
        }

        Ok(None)
    }
}

fn guess_syntax_by_contents(reader: &mut InputReader) -> Result<String> {
    use std::io::{copy, Cursor, Read};
    use std::process::{Command, Stdio};

    let child = Command::new("{LANGUESS}")
        .stdin(Stdio::piped())
        .stdout(Stdio::piped())
        .stderr(Stdio::piped())
        .spawn()?;

    let mut contents = reader.first_line.chain(&mut reader.inner);
    copy(&mut contents, &mut child.stdin.as_ref().unwrap())?;

    let output = child.wait_with_output()?;
    *reader = InputReader::new(Cursor::new(output.stdout));

    Ok(String::from_utf8_lossy(&output.stderr).to_string())
}
