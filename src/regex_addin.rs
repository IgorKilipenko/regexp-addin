use regex::Regex;

pub fn replace_text(text:String, pattern: String, rep: String, all: bool) -> Result<String, Box<dyn std::error::Error>> {
    let re = Regex::new(&pattern)?;
    let replaced_text = match all { 
        true => re.replace_all(&text, rep).to_string(),
        _ => re.replace(&text, rep).to_string()
    };
    Ok(replaced_text)
}
