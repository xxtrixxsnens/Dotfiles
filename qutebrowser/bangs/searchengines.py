import json
import os

# Expects to file with the given data in the format of duckduckbangs (2025)
# Returns dict of tag and searchengines.
def load_and_extract_bangs(filename):
    # Load JSON data from file
    with open(filename, 'r', encoding='utf-8') as f:
        data = json.load(f)

    bangs = data.get('bangs', [])
    result = {'DEFAULT': 'https://duckduckgo.com/?q={}'}

    for bang in bangs:
        key = bang.get('t')
        url = bang.get('u')

        if key and url:
            # Check if URL already has query parameters
            # And formats it for qutebrowser
            formatted_url = url.replace('{{{}}}', '{}')
            if not '{}' in formatted_url:
                if not '?' in formatted_url:
                    formatted_url = formatted_url + '?noquery={}' 
                else:
                    formatted_url = formatted_url + '&noquery={}' 

            result[key] = formatted_url

    return result
