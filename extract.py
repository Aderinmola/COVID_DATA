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

def load_data_to_db():
    covid_data = pd.read_csv(
        'covid_19_data.csv', 
        parse_dates=['ObservationDate', 'LastUpdate']
    )
    covid_data.rename(
                        columns={covid_data.columns[0]: 'serialNumber'},
                        errors="raise",
                        inplace=True
                    )
    covid_data['ObservationDate'] = covid_data['ObservationDate'].dt.date

    # transform the column 
    column_rename = covid_data.columns.map(lambda column: f"{column[0].lower()}{column[1:]}")
    covid_data.columns = list(column_rename)

    # load the data into database here
    engine = create_engine(f'postgresql+psycopg2://{db_user_name}:{db_password}@{host}:{port}/{db_name}')
    covid_data.to_sql('covid_19_data', con= engine, if_exists='replace', index= False)
    print('Data successfully written to PostgreSQL database!!!')

def main():
    download_google_drive_file()
    load_data_to_db()

main()


