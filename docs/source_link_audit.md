# Source Link Audit (Playwright)

- Date: 2026-02-14
- Method: Playwright browser navigation (`page.goto`, `domcontentloaded`, timeout 30s)
- Scope: `assets/data/foods.v1_2_0.json` 내 출처 URL 11개(중복 제거)
- Result: 11/11 reachable (HTTP 200)

| URL | HTTP | Final URL | Title |
| --- | --- | --- | --- |
| https://kb.rspca.org.au/knowledge-base/what-should-i-feed-my-birds/ | 200 | https://kb.rspca.org.au/categories/companion-animals/other-pets/birds/what-should-i-feed-my-birds | What should I feed my birds? - RSPCA Knowledgebase |
| https://lafeber.com/pet-birds/foods-toxic-pet-birds/ | 200 | https://lafeber.com/pet-birds/foods-toxic-pet-birds/ | Foods Toxic To Pet Birds – Pet Birds by Lafeber Co. |
| https://vcahospitals.com/know-your-pet/cockatiels-feeding | 200 | https://vcahospitals.com/know-your-pet/cockatiels-feeding | Cockatiels - Feeding \| VCA Animal Hospitals |
| https://vcahospitals.com/know-your-pet/lovebirds-feeding | 200 | https://vcahospitals.com/know-your-pet/lovebirds-feeding | Lovebirds - Feeding \| VCA Animal Hospitals |
| https://www.chewy.com/education/bird/feed-and-nutrition/seeds-vs-pellets | 200 | https://www.chewy.com/education/bird/feed-and-nutrition/seeds-vs-pellets | Seeds vs Pellets: Which Is Better for Your Pet Bird? \| Chewy |
| https://www.chewy.com/education/bird/food-and-nutrition/dont-feed-your-pet-bird-these-6-foods | 200 | https://www.chewy.com/education/bird/food-and-nutrition/dont-feed-your-pet-bird-these-6-foods | 14 Foods That Are Harmful or Poisonous to Pet Birds \| Chewy |
| https://www.chewy.com/education/bird/parrot/what-do-parrots-eat | 200 | https://www.chewy.com/education/bird/parrot/what-do-parrots-eat | What Do Parrots Eat? \| Chewy |
| https://www.merckvetmanual.com/bird-owners/choosing-and-taking-care-of-a-pet-bird/feeding-a-pet-bird | 200 | https://www.merckvetmanual.com/bird-owners/choosing-and-taking-care-of-a-pet-bird/feeding-a-pet-bird | Feeding a Pet Bird - Bird Owners - Merck Veterinary Manual |
| https://www.merckvetmanual.com/toxicology/food-hazards/avocado-persea-spp-toxicosis-in-animals | 200 | https://www.merckvetmanual.com/toxicology/food-hazards/avocado-persea-spp-toxicosis-in-animals | Avocado (Persea spp) Toxicosis in Animals - Toxicology - Merck Veterinary Manual |
| https://www.merckvetmanual.com/toxicology/food-hazards/garlic-and-onion-allium-spp-toxicosis-in-animals | 200 | https://www.merckvetmanual.com/toxicology/food-hazards/garlic-and-onion-allium-spp-toxicosis-in-animals | Garlic and Onion (Allium spp) Toxicosis in Animals - Toxicology - Merck Veterinary Manual |
| https://www.petmd.com/bird/foods-are-toxic-birds | 200 | https://www.petmd.com/bird/foods-are-toxic-birds | Toxic Foods for Birds \| PetMD |

## Notes

- 일부 사이트에서 써드파티 스크립트 경고/429/혼합 콘텐츠 경고가 발생했지만, 본문 URL 접근성과 문서 로드 자체는 정상입니다.
