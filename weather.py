# Hans Tang, 7/21/2022.
# Web scraping script to scrape weather data from Google Weather

from bs4 import BeautifulSoup as bs 
import requests

USER_AGENT = "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/94.0.4606.81 Safari/537.36"
# US english
LANGUAGE = "en-US,en;q=0.5"

def get_weather_data(url):
    session = requests.Session()
    session.headers['User-Agent']       = USER_AGENT
    session.headers['Accept-Language']  = LANGUAGE
    session.headers['Content-Language'] = LANGUAGE
    html = session.get(url)
    # make some soup
    soup = bs(html.text, "html.parser")
    # store results of dictionary
    result = {}
    # extract region
    result['region'] = soup.find("div", attrs={"id": "wob_loc"}).text
    # extract temp
    result['temp_now'] = soup.find("span", attrs={"id": "wob_tm"}).text
    # extract day and hour now
    result['dayhour'] = soup.find("div", attrs={"id": "wob_dts"}).text
    # extract actual weather
    result['weather_now'] = soup.find("span", attrs={"id": "wob_dc"}).text
    # extract precipitation
    result['precipitation'] = soup.find("span", attrs={"id": "wob_pp"}).text
    # extract % of humidity
    result['humidity'] = soup.find("span", attrs={"id": "wob_hm"}).text
    # extract wind
    result['wind'] = soup.find("span", attrs={"id": "wob_ws"}).text
    # extract the next few days' weather
    next_days = []
    days = soup.find("div", attrs={"id": "wob_dp"})
    for day in days.findAll("div", attrs={"class": "wob_df"}):
        # extract name of day
        day_name = day.findAll("div")[0].attrs['aria-label']
        # extract weather status for that day
        weather = day.find("img").attrs["alt"]
        temp = day.findAll("span", {"class": "wob_t"})
        # max temp in Fahr, use temp[0].text for Cels
        max_temp = temp[1].text
        # min temp in Fahr, use temp[2].text for Cels
        min_temp = temp[3].text
        next_days.append({"name": day_name, "weather": weather, "max_temp": max_temp, "min_temp": min_temp})
    # append to result
    result['next_days'] = next_days
    return result


if __name__ == "__main__":
    URL = "https://www.google.com/search?lr=lang_en&ie=UTF-8&q=weather"
    import argparse
    parser = argparse.ArgumentParser(description="Extracting Weather data by scraping from Google Weather")
    parser.add_argument("region", nargs="?", help="""Region to get weather for, must be available region.
                                        Default is your current location determined by your IP Address""", default="")
    # parse arguments
    args = parser.parse_args()
    region = args.region
    if region: 
        region = region.replace(" ", "+")
        URL += f"+{region}"
    # get data
    data = get_weather_data(URL)
    # print data
    print("Weather for:", data['region'])
    print("Currently:", data['dayhour'])
    print(f"Current Temp: {data['temp_now']}°F")
    print("Description:", data['weather_now'])
    print("Precipitation:", data['precipitation'])
    print("Humidity:", data['humidity'])
    print("Wind:", data['wind'])
    print("Next few days:")
    for dayweather in data['next_days']:
        print("="*40, dayweather['name'], "="*40)
        print("Description:", dayweather['weather'])
        print(f"Max Temp: {dayweather['max_temp']}°F")
        print(f"Min Temp: {dayweather['min_temp']}°F")

