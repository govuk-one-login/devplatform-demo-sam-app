import requests
import os

def create_github_release(token, repository, tag_name, release_name, target_commitish, body, draft=False, prerelease=False):
    """Creates a GitHub release using the API."""

    headers = {
        'Authorization': f'token {token}',
        'Accept': 'application/vnd.github.v3+json'
    }

    data = {
        'tag_name': tag_name,
        'name': release_name,
        'target_commitish': target_commitish,
        'body': body,
        'draft': draft,
        'prerelease': prerelease
    }

    url = f'https://api.github.com/repos/{repository}/releases'
    response = requests.post(url, headers=headers, json=data)

    if response.status_code == 201:  # 201 Created
        print("Release created successfully!")
        print(response.json())
    else:
        print(f"Error creating release: {response.status_code}")
        print(response.text)  # Print the error response for debugging

if __name__ == "__main__":
    print('main')
    token = os.environ['GITHUB_TOKEN']
    print(token)
    repository = os.environ['GITHUB_REPOSITORY']  # Get repo from environment
    print(repository)
    tag_name = 'v1.0.2'
    release_name = 'v1.0.2 Release'
    target_commitish = 'release-test'
    body = 'Release notes here'
    print('CREATING')
    create_github_release(token, repository, tag_name, release_name, target_commitish, body)

