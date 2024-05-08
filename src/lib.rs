use native_api_1c::{native_api_1c_core::ffi::connection::Connection, native_api_1c_macro::AddIn};
use std::{
    fs::{metadata, File},
    io::Read,
    sync::Arc,
};

#[derive(AddIn)]
pub struct ByteReader {
    #[add_in_con] // соединение с 1С для вызова внешних событий
    connection: Arc<Option<&'static Connection>>, // Arc для возможности многопоточности

    #[add_in_func(name = "ReadBytes", name_ru = "ПрочитатьБайты")]
    #[arg(Str)]
    #[returns(Blob, result)]
    read_bytes: fn(&Self, String) -> Result<Vec<u8>, Box<dyn std::error::Error>>,

    #[add_in_func(name = "FindText", name_ru = "НайтиТекст")]
    #[arg(Str)]
    #[returns(Str, result)]
    find_text: fn(&Self, String) -> Result<String, ()>,
}

impl ByteReader {
    pub fn new() -> Self {
        Self {
            connection: Arc::new(None),
            read_bytes: Self::read_bytes,
            find_text: Self::find_text,
        }
    }

    pub fn read_bytes(&self, path: String) -> Result<Vec<u8>, Box<dyn std::error::Error>> {
        let mut f = File::open(&path)?;
        let metadata = metadata(&path)?;
        let mut buffer = vec![0; metadata.len() as usize];
        f.read(&mut buffer)?;
        Ok(buffer)
    }

    pub fn find_text(&self, source_text: String) -> Result<String, ()> {
        Ok(String::from("Success"))
    }
}
