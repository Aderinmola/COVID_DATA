import requests
import pandas as pd
from sqlalchemy import create_engine
from dotenv import dotenv_values
from datetime import datetime


# A simple project to pull data from google drive

# Database credentials
config = dotenv_values()

db_name = config.get('DB_NAME')
db_user_name = config.get('DB_USER')
db_password = config.get('DB_PASSWORD')
host = config.get('DB_HOST')
port = config.get('DB_PORT')

link = "https://drive.google.com/file/d/1SzmRIwlpL5PrFuaUe_1TAcMV0HYHMD_b/view"

def download_google_drive_file():
    URL = "https://docs.google.com/uc"

    response = requests.get(URL, params= {'id': '1SzmRIwlpL5PrFuaUe_1TAcMV0HYHMD_b', 'export': 'download'}, stream=True)
    with open("covid_19_data.csv", "wb") as f:
        f.write(response.content)
    print('Data successfully downloaded to a file!!!')

def main():
    download_google_drive_file()

main()
