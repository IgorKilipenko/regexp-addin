use native_api_1c::{native_api_1c_core::ffi::connection::Connection, native_api_1c_macro::AddIn};
use std::sync::Arc;

mod regex_addin;

#[derive(AddIn)]
pub struct TestAddIn {
    #[add_in_con]
    connection: Arc<Option<&'static Connection>>,

    #[add_in_func(name = "ReplaceText", name_ru = "ЗаменитьТекст")]
    #[arg(Str)]
    #[arg(Str)]
    #[arg(Str)]
    #[arg(Bool, default = false)]
    #[returns(Str, result)]
    replace_text:
        fn(&Self, String, String, String, bool) -> Result<String, Box<dyn std::error::Error>>,
}

impl TestAddIn {
    pub fn new() -> Self {
        Self {
            connection: Arc::new(None),
            replace_text: Self::replace_text,
        }
    }

    pub fn replace_text(
        &self,
        text: String,
        pattern: String,
        rep: String,
        all: bool,
    ) -> Result<String, Box<dyn std::error::Error>> {
        regex_addin::replace_text(text, pattern, rep, all)
    }
}
