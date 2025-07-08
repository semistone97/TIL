## 오늘은 메모리 얘기로 시작.
>   - x64, x32는 비트 관련 아키텍쳐
>   - mac도 그렇다. M시리즈는 CPU면서 좀 더 많은 기능을 담고 있음.
>       - 당연하지만 핸드폰이나 전자시계에도 CPU는 있음.
>   - 갤럭시는 스냅드래곤, 액시노스(CPU 제품명)
>       - 스냅드래곤: 퀄컴 / - 액시노스: 삼성
>   - SOC(System on a Chip): CPU 하나에 메모리, 그래픽 하나에 떄려박은 것.(요즘 컴퓨터가 그럼)
>   - ARM(Acorn RISC Machine)
>       - 새로운 아키텍쳐
>       - ARM은 전성비가 좋음. 열이 안 남.
>       - 열이 안 나서 배터리 효율이 좋아보임.
---
## RAM
> CPU는 도구? 디스크는 창고
> 작업이라고 치면 RAM은 작업대.
>   - 한 칸(비트)에는 1이나 0만 저장
> 1바이트는 2의 8승, 16진수
>   - 색깔코드도 16진수(6개)
> 메모리는 순간 보여주는 것, 디스크는 영구저장
> 삭제는 데이터를 지운 게 아니고, 점유된 메모리를 해제한 거라서 그럼.
>   - 그래서 디스크 내에 있는 데이터를 전부 지우려면 전부 다 덮어씌워야 하고, 개 빡셈.
> 메모리의 효율성은 시간과 공간의 밸런스(오래쓰기, 메모리 많이 점유하기)
>   - ***시간복잡도 x 공간복잡도***
>   - CROSS JOIN이 공간을 많이 쓰는 케이스
>   - ORDER BY가 시간을 많은 쓰는 케이스

---
# PostgreSQL
> ** SELECT version이 뭐하는 거였지 **
---
## EXPLAIN
> -- Seq Scan on large_customers  (cost=0.00..3746.00 rows=9953 width=160)
> -- Filter: (customer_type = 'VIP'::text)
- cost: 비용(낮을수록 좋음)
> *일단 지금은 답이 나오는 게 중요하지만, 나중에 가면 최적화된 컬럼을 짜는 게 중요*
- rows x width : 현재 사용하는 총 메모리 사용량(이 역시 낮으면 좋음)

## EXPLAIN ANALYZE
> "Seq Scan on large_customers  (cost=0.00..3746.00 rows=9953 width=160) (actual time=0.262..89.798 rows=10075 loops=1)"
- seq scan :
    (1) 인덱스가 없고
    (2) 테이블 대부분의 행을 읽어야 하고
    (3) 순차 스캔이 빠를 때.
> "  Filter: (customer_type = 'VIP'::text)"
> "  Rows Removed by Filter: 89925"
> "Planning Time: 3.561 ms"
> "Execution Time: 91.497 ms"
> ***EXPLAIN은 예상, EXPLAIN ANALYZE는 실제 사용량.***

# INDEX
> 데이터가 너무 많은데 INDEX를 가져오면 되려 느려질 때가 있음.
> ***INDEX부터는 정답이 없음. 최적화에 관련된 내용이기 때문***
### ***인덱스 유튜브 보면서 더 공부하자***
---
## 내일은 실제 코딩을 해볼 것.