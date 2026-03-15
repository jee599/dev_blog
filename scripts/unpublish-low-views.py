#!/usr/bin/env python3
"""
DEV.to에서 조회수 50 미만인 한국어 글을 unpublish한다.

Usage:
  DEVTO_KEY=xxx python3 scripts/unpublish-low-views.py
  DEVTO_KEY=xxx python3 scripts/unpublish-low-views.py --dry-run
  DEVTO_KEY=xxx python3 scripts/unpublish-low-views.py --threshold 100
"""

import os
import sys
import json
import time
import argparse
import urllib.request
import urllib.error

API_KEY = os.environ.get('DEVTO_KEY', '')
BASE = 'https://dev.to/api'
HEADERS = {
    'api-key': API_KEY,
    'Accept': 'application/vnd.forem.api-v1+json',
    'User-Agent': 'dev-blog-tools/1.0',
}


def api_call(method, url, payload=None):
    data = json.dumps(payload).encode('utf-8') if payload else None
    headers = dict(HEADERS)
    if data:
        headers['Content-Type'] = 'application/json'
    req = urllib.request.Request(url, data=data, method=method, headers=headers)
    try:
        resp = urllib.request.urlopen(req)
        return resp.status, json.loads(resp.read())
    except urllib.error.HTTPError as e:
        return e.code, e.read().decode('utf-8', errors='replace')


def get_all_articles():
    articles = []
    page = 1
    while True:
        code, body = api_call('GET', f'{BASE}/articles/me?per_page=100&page={page}')
        if code != 200 or not isinstance(body, list) or len(body) == 0:
            break
        articles.extend(body)
        if len(body) < 100:
            break
        page += 1
    return articles


def is_korean(title):
    for ch in title:
        if '\uac00' <= ch <= '\ud7a3':
            return True
    return False


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument('--dry-run', action='store_true', help='실제 unpublish 안 함')
    parser.add_argument('--threshold', type=int, default=50, help='조회수 기준 (기본 50)')
    args = parser.parse_args()

    if not API_KEY:
        print('ERROR: DEVTO_KEY 환경변수 필요', file=sys.stderr)
        sys.exit(1)

    print(f'DEV.to 글 목록 가져오는 중...')
    articles = get_all_articles()
    print(f'총 {len(articles)}개 글')

    # 한국어 + 조회수 50 미만 + published 필터
    targets = []
    for art in articles:
        title = art.get('title', '')
        views = art.get('page_views_count', 0) or 0
        published = art.get('published', False)

        if published and is_korean(title) and views < args.threshold:
            targets.append(art)

    print(f'\n한국어 + 조회수 {args.threshold} 미만 + published: {len(targets)}개')
    print()

    for art in sorted(targets, key=lambda a: a.get('page_views_count', 0)):
        aid = art['id']
        title = art['title']
        views = art.get('page_views_count', 0)
        print(f'  [{views:3d} views] {title} (id={aid})')

        if not args.dry_run:
            code, result = api_call('PUT', f'{BASE}/articles/{aid}', {
                'article': {'published': False}
            })
            if code == 200:
                print(f'    → unpublished')
            else:
                print(f'    → FAILED: {code} {str(result)[:200]}')
            time.sleep(2)

    if args.dry_run:
        print(f'\n--dry-run 모드: 실제 unpublish 안 함. 위 목록 확인 후 --dry-run 빼고 실행해라.')
    else:
        print(f'\n완료: {len(targets)}개 unpublished')


if __name__ == '__main__':
    main()
