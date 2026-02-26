# dev_blog Status

> Updated: 2026-02-26
> Canonical root: `/Users/jidong/dev_blog`
> Master plan: `docs/PRODUCTION_MASTER_PLAN_2026-02-26.md`
> Writing spec: `prompts/blog-writing.md`

## Phase Progress

| Phase | Status | Gate |
|------:|:------:|------|
| Phase 0: 자동 발행 파이프라인 | ✅ | `posts/*.md` push → Actions publish → `id/date` 자동 반영 |
| Phase 1: 글 생산 표준화 | ⏳ | STATUS에 다음 후보 유지 + KO/EN 페어링 |
| Phase 2: 품질 Gate 자동화 | ⏳ | (선택) 프론트매터/태그 검사 자동화 |

## North Star / Guardrails

- North Star: 발행된 글 수 / 주
- Guardrails: Actions 실패율, worklog→posts 승격률, 한/영 페어 완성률

## Latest Change

- Master plan + STATUS 문서 추가(운영 표준화)

## Verification

### Publishing pipeline

- GitHub Actions 로그 확인
- `publish-log.txt` 확인

### Worklog generator

```bash
cd /Users/jidong/dev_blog
bash tools/install-worklog-hooks.sh
# 그 다음 다른 레포에서 커밋 1번 만들면 logs/YYYY-MM-DD/ 아래에 파일 생성됨
```

## Next Up (P0)

- 이번 주 발행 목표 1편 확정(KO/EN)
- logs에서 소재 1개 선택 → posts로 승격
- 새 글은 `published: false`로 시작

## Worklog

- 자동 로그: `logs/YYYY-MM-DD/<project>-<sha>.md`
- 발행물: `posts/*.md`
- 실패 기록: `publish-log.txt`
