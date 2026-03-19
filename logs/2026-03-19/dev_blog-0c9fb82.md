---
title: "[dev_blog] fix: add devto article id and fix tags format for contextzip post"
published: false
description: "dev_blog 작업 로그. 커밋 0c9fb82."
tags: ai, webdev, productivity, buildinpublic
---

fix: add devto article id and fix tags format for contextzip post

이 커밋은 기록용이다.

---

이유는 이거다.

(여기에 배경을 짧게 쓴다. 길어지면 문단을 나눈다.)

---

바뀐 파일은 이렇다.

     A	.astro/content.d.ts
 A	.astro/types.d.ts
 A	logs/2026-02-26/coffeechat-00081ea.md
 A	logs/2026-02-26/coffeechat-1545424.md
 A	logs/2026-02-26/coffeechat-46b407f.md
 A	logs/2026-02-26/coffeechat-61cfbd2.md
 A	logs/2026-02-26/dev_blog-19023be.md
 A	logs/2026-02-26/dev_blog-67b1e00.md
 A	logs/2026-02-26/dev_blog-8e04253.md
 A	logs/2026-02-26/dev_blog-b698760.md
 A	logs/2026-02-26/dev_blog-c970cc1.md
 A	logs/2026-02-26/dev_blog-e9fe755.md
 A	logs/2026-02-26/dev_blog-fb2b6ad.md
 A	logs/2026-02-26/saju-2b4f431.md
 A	logs/2026-02-26/saju-8e986e7.md
 A	logs/2026-02-26/saju-dfea4de.md
 A	logs/2026-02-26/tradingbot-02b4f4a.md
 A	logs/2026-02-26/tradingbot-2463718.md
 A	logs/2026-02-26/tradingbot-6714ec4.md
 A	logs/2026-02-26/tradingbot-72b2041.md
 A	logs/2026-02-26/tradingbot-862454f.md
 A	logs/2026-02-26/tradingbot-f109cde.md
 A	logs/2026-02-27/clever-blackburn-a54d04a.md
 A	logs/2026-02-27/nervous-bhabha-ea31ee7.md
 A	logs/2026-02-27/nervous-bhabha-fcb3847.md
 A	logs/2026-02-27/saju-5d00dea.md
 A	logs/2026-02-27/saju-5fd1201.md
 A	logs/2026-02-27/saju-63edc05.md
 A	logs/2026-02-27/saju-702ad91.md
 A	logs/2026-02-27/saju-91395f0.md
 A	logs/2026-02-27/saju-a8624a5.md
 A	logs/2026-02-27/saju-fc43725.md
 A	logs/2026-02-28/amazing-cori-01ef253.md
 A	logs/2026-02-28/amazing-cori-04e4b3b.md
 A	logs/2026-02-28/amazing-cori-0abf59d.md
 A	logs/2026-02-28/amazing-cori-30fb850.md
 A	logs/2026-02-28/amazing-cori-59406ed.md
 A	logs/2026-02-28/amazing-cori-594e0bd.md
 A	logs/2026-02-28/amazing-cori-67fbc53.md
 A	logs/2026-02-28/amazing-cori-7b4eceb.md
 A	logs/2026-02-28/amazing-cori-7c63c89.md
 A	logs/2026-02-28/amazing-cori-9c52fd9.md
 A	logs/2026-02-28/amazing-cori-9cb7f9e.md
 A	logs/2026-02-28/amazing-cori-a88c6c6.md
 A	logs/2026-02-28/amazing-cori-d47c170.md
 A	logs/2026-02-28/amazing-cori-de03079.md
 A	logs/2026-02-28/amazing-cori-e053882.md
 A	logs/2026-02-28/amazing-cori-e6dcd70.md
 A	logs/2026-02-28/amazing-cori-f950149.md
 A	logs/2026-02-28/coffeechat-05bdb65.md
 A	logs/2026-02-28/coffeechat-060eb90.md
 A	logs/2026-02-28/coffeechat-07d9273.md
 A	logs/2026-02-28/coffeechat-18d2faa.md
 A	logs/2026-02-28/coffeechat-63e9639.md
 A	logs/2026-02-28/coffeechat-781bd50.md
 A	logs/2026-02-28/coffeechat-8d2468f.md
 A	logs/2026-02-28/coffeechat-9c6669f.md
 A	logs/2026-02-28/coffeechat-9ec0f04.md
 A	logs/2026-02-28/coffeechat-a0150c3.md
 A	logs/2026-02-28/coffeechat-adc9fd2.md
 A	logs/2026-02-28/coffeechat-c78daae.md
 A	logs/2026-02-28/coffeechat-e44afb6.md
 A	logs/2026-02-28/coffeechat-eb2beb4.md
 A	logs/2026-02-28/dev_blog-4b55bd0.md
 A	logs/2026-02-28/dev_blog-a7a8a22.md
 A	logs/2026-02-28/nifty-payne-d06943e.md
 A	logs/2026-02-28/saju-2c91f61.md
 A	logs/2026-02-28/serene-mirzakhani-8326291.md
 A	logs/2026-03-01/amazing-cori-04a6d5e.md
 A	logs/2026-03-01/amazing-cori-15b4aa9.md
 A	logs/2026-03-01/amazing-cori-17ed94c.md
 A	logs/2026-03-01/amazing-cori-2de080d.md
 A	logs/2026-03-01/amazing-cori-3ab8dd8.md
 A	logs/2026-03-01/amazing-cori-468e6e4.md
 A	logs/2026-03-01/amazing-cori-4a306b9.md
 A	logs/2026-03-01/amazing-cori-4fffb48.md
 A	logs/2026-03-01/amazing-cori-5d16d7e.md
 A	logs/2026-03-01/amazing-cori-699dbbf.md
 A	logs/2026-03-01/amazing-cori-730a928.md
 A	logs/2026-03-01/amazing-cori-78e513f.md
 A	logs/2026-03-01/amazing-cori-8801bd2.md
 A	logs/2026-03-01/amazing-cori-945dec0.md
 A	logs/2026-03-01/amazing-cori-9d5b8ab.md
 A	logs/2026-03-01/amazing-cori-a90a35a.md
 A	logs/2026-03-01/amazing-cori-b043738.md
 A	logs/2026-03-01/amazing-cori-db09925.md
 A	logs/2026-03-01/amazing-cori-df09090.md
 A	logs/2026-03-01/amazing-cori-e03c77f.md
 A	logs/2026-03-01/amazing-cori-e2fccbf.md
 A	logs/2026-03-01/amazing-cori-f057bc0.md
 A	logs/2026-03-01/amazing-cori-f921641.md
 A	logs/2026-03-01/coffeechat-16d0441.md
 A	logs/2026-03-01/coffeechat-58142b6.md
 A	logs/2026-03-01/coffeechat-5ead48b.md
 A	logs/2026-03-01/coffeechat-61496f4.md
 A	logs/2026-03-01/coffeechat-652d3ee.md
 A	logs/2026-03-01/coffeechat-a9dc159.md
 A	logs/2026-03-01/coffeechat-b01002d.md
 A	logs/2026-03-01/coffeechat-c0fb8b8.md
 A	logs/2026-03-01/saju-ed0cd17.md
 A	logs/2026-03-02/amazing-cori-1717a69.md
 A	logs/2026-03-02/amazing-cori-1feecfd.md
 A	logs/2026-03-02/amazing-cori-2a0b40c.md
 A	logs/2026-03-02/amazing-cori-497edf7.md
 A	logs/2026-03-02/amazing-cori-7ec6f82.md
 A	logs/2026-03-02/amazing-cori-8ad3e97.md
 A	logs/2026-03-02/amazing-cori-a9ee2b3.md
 A	logs/2026-03-02/amazing-cori-b2a59a0.md
 A	logs/2026-03-02/amazing-cori-bc05356.md
 A	logs/2026-03-02/amazing-cori-d88c9e1.md
 A	logs/2026-03-02/amazing-cori-e4320b9.md
 A	logs/2026-03-02/amazing-cori-f7c892b.md
 A	logs/2026-03-02/saju-11d8b7a.md
 A	logs/2026-03-02/saju-1a755cc.md
 A	logs/2026-03-02/saju-1ee1223.md
 A	logs/2026-03-02/saju-2c73942.md
 A	logs/2026-03-02/saju-564e740.md
 A	logs/2026-03-02/saju-594247c.md
 A	logs/2026-03-02/saju-62080ec.md
 A	logs/2026-03-02/saju-633b504.md
 A	logs/2026-03-02/saju-6896662.md
 A	logs/2026-03-02/saju-9b9240f.md
 A	logs/2026-03-02/saju-b6b31af.md
 A	logs/2026-03-02/saju-b8d0bb7.md
 A	logs/2026-03-02/saju-bef03ca.md
 A	logs/2026-03-02/saju-c29c916.md
 A	logs/2026-03-02/saju-d6ee62a.md
 A	logs/2026-03-02/saju-e60d817.md
 A	logs/2026-03-03/dev_blog-26ad664.md
 A	logs/2026-03-03/dev_blog-7596fa6.md
 A	logs/2026-03-03/dev_blog-9ba3a32.md
 A	logs/2026-03-03/dev_blog-da1cbe8.md
 A	logs/2026-03-03/dev_blog-fa656a9.md
 A	logs/2026-03-03/romantic-sammet-17b7307.md
 A	logs/2026-03-03/romantic-sammet-1deef42.md
 A	logs/2026-03-03/romantic-sammet-5da8331.md
 A	logs/2026-03-03/romantic-sammet-852dda2.md
 A	logs/2026-03-03/romantic-sammet-91e4cf9.md
 A	logs/2026-03-03/romantic-sammet-a39d0f9.md
 A	logs/2026-03-03/romantic-sammet-bb56d6a.md
 A	logs/2026-03-03/romantic-sammet-d4d1ac8.md
 A	logs/2026-03-03/romantic-sammet-d5771ce.md
 A	logs/2026-03-03/saju-29de338.md
 A	logs/2026-03-03/saju-60585a8.md
 A	logs/2026-03-03/saju-9d281fb.md
 A	logs/2026-03-03/saju-9ee0905.md
 A	logs/2026-03-03/saju-b8dd77c.md
 A	logs/2026-03-03/saju-cc86b7a.md
 A	logs/2026-03-04/dev_blog-0c7b24a.md
 A	logs/2026-03-04/dev_blog-309fbb6.md
 A	logs/2026-03-04/dev_blog-6e1c0aa.md
 A	logs/2026-03-04/dev_blog-7ffbccf.md
 A	logs/2026-03-04/romantic-sammet-ab0050d.md
 A	logs/2026-03-04/saju-1bc622c.md
 A	logs/2026-03-04/saju-4fa04b0.md
 A	logs/2026-03-04/saju-74742f0.md
 A	logs/2026-03-04/saju-8094158.md
 A	logs/2026-03-04/saju-81f0bac.md
 A	logs/2026-03-04/saju-931cdff.md
 A	logs/2026-03-04/saju-9ac5cc0.md
 A	logs/2026-03-04/saju-a15e725.md
 A	logs/2026-03-04/saju-b38acdf.md
 A	logs/2026-03-04/saju-c4c8f2d.md
 A	logs/2026-03-05/saju-1fde498.md
 A	logs/2026-03-05/saju-2d005bf.md
 A	logs/2026-03-05/saju-2e57533.md
 A	logs/2026-03-05/saju-37cfdac.md
 A	logs/2026-03-05/saju-48083c3.md
 A	logs/2026-03-05/saju-7feb33f.md
 A	logs/2026-03-05/saju-93038cb.md
 A	logs/2026-03-05/saju-9638f27.md
 A	logs/2026-03-05/saju-967467b.md
 A	logs/2026-03-05/saju-96a6b8a.md
 A	logs/2026-03-05/saju-a6379ed.md
 A	logs/2026-03-05/saju-e4c4e34.md
 A	logs/2026-03-06/dev_blog-0981c6a.md
 A	logs/2026-03-06/dev_blog-45e2f3d.md
 A	logs/2026-03-06/dev_blog-470a8bd.md
 A	logs/2026-03-06/dev_blog-cb51eb1.md
 A	logs/2026-03-09/dev_blog-2e3bf45.md
 A	logs/2026-03-09/dev_blog-570c162.md
 A	logs/2026-03-09/dev_blog-b6427d6.md
 A	logs/2026-03-14/dev_blog-1be4130.md
 A	logs/2026-03-14/dev_blog-20a53c6.md
 A	logs/2026-03-14/dev_blog-2db63c6.md
 A	logs/2026-03-14/dev_blog-4583fec.md
 A	logs/2026-03-14/dev_blog-570ed33.md
 A	logs/2026-03-14/dev_blog-5a9e675.md
 A	logs/2026-03-14/dev_blog-5b899f4.md
 A	logs/2026-03-14/dev_blog-81d9b9b.md
 A	logs/2026-03-14/dev_blog-910e21d.md
 A	logs/2026-03-14/dev_blog-bc6bbb2.md
 A	logs/2026-03-14/dev_blog-f2fc77e.md
 A	logs/2026-03-14/dev_blog-f68751a.md
 A	logs/2026-03-15/coffeechat-027c470.md
 A	logs/2026-03-15/coffeechat-1a15c04.md
 A	logs/2026-03-15/coffeechat-24d7aed.md
 A	logs/2026-03-15/coffeechat-2d5fc7f.md
 A	logs/2026-03-15/coffeechat-53ba401.md
 A	logs/2026-03-15/coffeechat-6c43f73.md

---

검증은 이렇게 했다.

    (여기에 실제로 돌린 커맨드를 붙인다)

PASS/FAIL을 한 줄로 적는다.

---

메모.

(의도, 리스크, 롤백, 다음 작업을 짧게)

---

Refs.

commit 0c9fb82
branch main
remote git@github.com:jee599/dev_blog.git

> "Ship small. Log everything."
