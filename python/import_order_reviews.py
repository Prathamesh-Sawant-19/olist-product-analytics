import os
from dotenv import load_dotenv
load_dotenv()
import pandas as pd
import mysql.connector
from mysql.connector import Error

CSV_PATH = "data/raw/olist_order_reviews_dataset.csv"

DB_CONFIG = {
    "host": os.getenv("DB_HOST"),
    "user": os.getenv("DB_USER"),
    "password": os.getenv("DB_PASSWORD"),
    "database": os.getenv("DB_NAME")
}
def clean_value(value):
    if pd.isna(value):
        return None
    return value

def main():
    try:
        print("Reading CSV...")
        df = pd.read_csv(CSV_PATH)

        print(f"Rows loaded from CSV: {len(df)}")
        print(df.head())

        df["review_creation_date"] = pd.to_datetime(df["review_creation_date"], errors="coerce")
        df["review_answer_timestamp"] = pd.to_datetime(df["review_answer_timestamp"], errors="coerce")

        connection = mysql.connector.connect(**DB_CONFIG)
        cursor = connection.cursor()

        insert_query = """
        INSERT INTO order_reviews (
            review_id,
            order_id,
            review_score,
            review_comment_title,
            review_comment_message,
            review_creation_date,
            review_answer_timestamp
        )
        VALUES (%s, %s, %s, %s, %s, %s, %s)
        """

        records = []
        for _, row in df.iterrows():
            records.append((
                clean_value(row["review_id"]),
                clean_value(row["order_id"]),
                int(row["review_score"]) if not pd.isna(row["review_score"]) else None,
                clean_value(row["review_comment_title"]),
                clean_value(row["review_comment_message"]),
                clean_value(row["review_creation_date"]),
                clean_value(row["review_answer_timestamp"])
            ))

        print("Inserting records into MySQL...")
        cursor.executemany(insert_query, records)
        connection.commit()

        print(f"Inserted rows: {cursor.rowcount}")

        cursor.close()
        connection.close()

    except Error as e:
        print(f"MySQL error: {e}")
    except Exception as e:
        print(f"General error: {e}")

if __name__ == "__main__":
    main()
    