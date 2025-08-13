# 범용 이상치 탐지 함수

# 라이브러리 설치

import seaborn as sns
import numpy as np
import pandas as pd
import matplotlib.pyplot as plt
from IPython.display import display
from scipy.spatial import distance
from scipy.stats import chi2
from sklearn.preprocessing import StandardScaler
from sklearn.ensemble import IsolationForest

import warnings
warnings.filterwarnings('ignore', category=UserWarning)

plt.rcParams['font.family'] = 'GmarketSans'
plt.rcParams['axes.unicode_minus'] = False


# it was IQR, 3∂
# 이상치를 범용적으로 탐지하는 건 꽤 어려운 작업임(그나마가 IQR)
def outlier_detection(df: pd.DataFrame, chi_q=0.999, iso_cont=0.1, final_threshold=2):

    if df.isna().values.any():
        print('결측치 확인. 제거 후 다시 시도하세요.')
        return

    print('=== 종합 이상값 탐지 시스템 ===')
    df_copy = df.copy()
    numeric_data = df_copy.select_dtypes(include=['number']) # 우리는 수치형 데이터만 확인할 거기 때문에.


    # 1. IQR 이상값
    print('1. 일변량 이상값 탐지 (IQR 방법)')   # 변수 하나만 보고 이상한지 아닌지 판단하겠다.(키 250)
    # 다변량: 종합적으로 보면 이상해(키 190 몸무게 45)
    univariate_outliers = pd.DataFrame(index=df_copy.index)
    
    for col in numeric_data.columns:
        Q1 = df_copy[col].quantile(0.25)
        Q3 = df_copy[col].quantile(0.75)
        IQR = Q3 - Q1
        lower_bound = Q1 - 1.5 * IQR
        upper_bound = Q3 + 1.5 * IQR

        outliers_mask = (df_copy[col] < lower_bound ) | (df_copy[col] > upper_bound)
        univariate_outliers[col] = outliers_mask

        # display(univariate_outliers)    # 이 때 나타나는 True는 한 줄의 col 내에서 이상한 값들.
        outlier_count = outliers_mask.sum()
        if outlier_count:
            print(f'  {col}: {outlier_count}개 ({outlier_count / len(df_copy) * 100:.1f}%)')
    
    # 2. 마할라노비스 거리 기반 다변량 이상값
    # => 데이터가 정규분포를 따를 때, 유용함.
    print('\n2. 다변량 이상값 탐지 (마할라노비스 거리)')
    scaler = StandardScaler() # 인스턴스 만들기
    
    # 평균 0, 표준편차 1로 조정된 데이터
    scaled_df = pd.DataFrame(
        scaler.fit_transform(numeric_data),
        columns=numeric_data.columns,
        index=numeric_data.index
    )
    # 데이터 평균 벡터
    mean = scaled_df.mean().values
    # 공분산 행렬
    cov_matrix = np.cov(scaled_df, rowvar=False)
    # 공분산 행렬의 역행렬
    inv_cov_matrix = np.linalg.pinv(cov_matrix)
    # 마할라노비스 거리 계산
    mahal_distance = scaled_df.apply(lambda row: distance.mahalanobis(row, mean, inv_cov_matrix), axis=1)
    

    # 이상치 기준점(임계점, threshold) 지정 (카이제곱 분포 기준 ->  0.95, 0.99, 0.999)
    threshold = chi2.ppf(chi_q, len(numeric_data.columns)) ** 0.5
    mahal_outliers = mahal_distance > threshold
    print(f' 임계값(거리): {threshold:.2f}')
    print(f' 다변량 이상값: {mahal_outliers.sum()}개 ({mahal_outliers.mean() * 100:.1f}%)')

    # 3. IsolationForest기반 다변량 이상값
    # 데이터가 정상인지 비정상인지를 나눔.
    # 얘는 마할라노비스랑 다르게, 데이터 이상치가 너무 복잡할 때 사용.
    print('\n3. 다변량 이상값 탐지(Isolation Forest)')
    iso_forest = IsolationForest(contamination=iso_cont, random_state = 42)
    isolation_outliers = iso_forest.fit_predict(scaled_df) == -1
    isolation_scores = iso_forest.score_samples(scaled_df)
    print(f'  Isolation Forest 이상값: {isolation_outliers.sum()}개 ({isolation_outliers.mean() * 100:.1f}%)')

    
    # 5. 종합판정
    outlier_summary = pd.DataFrame({
        '일변량': univariate_outliers.sum(axis=1) > 0,
        'Mahal Dist': mahal_outliers,
        'Iso Forest': isolation_outliers,
    })
    outlier_summary['총이상값수'] = outlier_summary.sum(axis=1)
    final_outliers = outlier_summary['총이상값수'] >= final_threshold
    print(f'\n == 최종 이상값: {final_outliers.sum()}개 ({final_outliers.mean() * 100:.1f}%)')
    
    return outlier_summary, final_outliers
# summary, final_outliers = outlier_detection(df_knn, chi_q=0.999, iso_cont=0.1, final_threshold=2)