import requests
from bs4 import BeautifulSoup

HEADERS = {
    'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.124 Safari/537.36'
}

def seo_audit(url):
    try:
        response = requests.get(url, headers=HEADERS)
        soup = BeautifulSoup(response.content, 'html.parser')


        # Title tag
        title = soup.title.string if soup.title else "Title tag missing"
        print(f"Title: {title}")
        print(f"Title Length: {len(title)} characters")

        # Meta description
        meta_description = soup.find('meta', attrs={'name': 'description'})
        if meta_description:
            print(f"Meta Description: {meta_description['content']}")
            print(f"Meta Description Length: {len(meta_description['content'])} characters")
        else:
            print("Meta description tag missing")

        # Check H1 tags
        h1_tags = soup.find_all('h1')
        if h1_tags:
            for i, h1 in enumerate(h1_tags):
                print(f"H1-{i+1}: {h1.text.strip()}")
                print(f"H1-{i+1} Length: {len(h1.text.strip())} characters")
        else:
            print("No H1 tags found")

        # Check H2 tags
        h2_tags = soup.find_all('h2')
        if h2_tags:
            for i, h2 in enumerate(h2_tags):
                print(f"H2-{i+1}: {h2.text.strip()}")
                print(f"H2-{i+1} Length: {len(h2.text.strip())} characters")
        else:
            print("No H2 tags found")

        # Check for canonical link
        canonical = soup.find('link', attrs={'rel': 'canonical'})
        if canonical:
            print(f"Canonical Link: {canonical['href']}")
        else:
            print("No canonical link found")

        # Alt text for images
        images_without_alt = [img['src'] for img in soup.find_all('img', alt=False)]
        if images_without_alt:
            print(f"There are {len(images_without_alt)} images without alt text:")
            for img in images_without_alt:
                print(f"Image: {img}")

        else:
            print("All images have alt text")

        # Check for robots.txt
        robots_url = '/'.join(url.split('/')[:3]) + '/robots.txt'
        robots_response = requests.get(robots_url)
        if robots_response.status_code == 200:
            print(f"Robots.txt is present at {robots_url}")
        else:
            print("No robots.txt found")
    # Check for meta robots tag
        meta_robots = soup.find('meta', attrs={'name': 'robots'})
        if meta_robots:
            print(f"Meta Robots: {meta_robots['content']}")
        else:
            print("No meta robots tag found")

        # Check for SSL
        if 'https' in url:
            print("SSL (HTTPS) is used.")
        else:
            print("No SSL (HTTPS) detected.")

        # Check for broken links (only within the same domain to prevent the script from crawling the entire web)
        broken_links = []
        links_to_check = [a['href'] for a in soup.find_all('a', href=True) if a['href'].startswith(('http://', 'https://')) and url.split('//')[1].split('/')[0] in a['href']]
        # Limit to only first 5 links
        links_to_check = links_to_check[:5]

        for link in links_to_check:
            resp = requests.head(link, allow_redirects=True, headers=HEADERS)
            if resp.status_code >= 400:
                broken_links.append(link)

        if broken_links:
            print(f"Found {len(broken_links)} broken links among the first 5 checked:")
            for link in broken_links:
                print(link)
        else:
            print("No broken links detected among the first 5 checked.")
    except requests.exceptions.ConnectionError as e:
        print(f"Connection Error: {e}")
    except requests.exceptions.RequestException as e:
        print(f"Request Exception: {e}")

if __name__ == "__main__":
    url = input("Enter the URL to audit: ")
    seo_audit(url)



