use native_api_1c::{native_api_1c_core::ffi::connection::Connection, native_api_1c_macro::AddIn, native_api_1c_macro::extern_functions};
use std::sync::Arc;

mod regex_addin;

#[derive(AddIn)]
pub struct RegExp {
    #[add_in_con]
    connection: Arc<Option<&'static Connection>>,

    #[add_in_func(name = "ReplaceText", name_ru = "ЗаменитьТекст")]
    #[arg(ty = Str)]
    #[arg(ty = Str)]
    #[arg(ty = Str)]
    #[arg(ty = Bool, default = false)]
    #[returns(ty = Str, result)]
    #[allow(clippy::type_complexity)]
    replace_text: fn(&Self, String, String, String, bool) -> Result<String, Box<dyn std::error::Error>>,

    #[add_in_prop(ty = Str, name = "Version", name_ru = "Версия", readable)]
    pub get_version: String,
}

impl Default for RegExp {
    fn default() -> Self {
        Self {
            connection: Arc::new(None),
            replace_text: Self::replace_text,
            get_version: "".to_string(),
        }
    }
}

impl RegExp {
    pub fn new() -> Self {
        Self::default()
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

    pub fn get_version(&self) -> String {
        env!("CARGO_PKG_VERSION").to_string()
    }
}

extern_functions! {
    RegExp::default(),
}
