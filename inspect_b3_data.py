import json
import requests
import pandas as pd

B3_URL = "https://sistemaswebb3-listados.b3.com.br/indexProxy/indexCall/GetPortfolioDay/eyJsYW5ndWFnZSI6InB0LWJyIiwicGFnZU51bWJlciI6MSwicGFnZVNpemUiOjEyMCwiaW5kZXgiOiJJQk9WIiwic2VnbWVudCI6IjEifQ=="


def inspect_b3_data():
    response = requests.get(B3_URL, timeout=30)
    if response.status_code == 200:
        data = response.json().get("results")
        if data and len(data) > 0:
            print("First record structure:")
            print(json.dumps(data[0], indent=2))

            print(f"\nTotal records: {len(data)}")
            print(f"Available columns: {list(data[0].keys())}")

            # Create DataFrame to see column types
            df = pd.DataFrame(data)
            print(f"\nDataFrame info:")
            print(df.info())
            print(f"\nDataFrame columns: {df.columns.tolist()}")

        return data
    else:
        print(f"Failed to fetch data: {response.status_code}")
        return None


if __name__ == "__main__":
    inspect_b3_data()
