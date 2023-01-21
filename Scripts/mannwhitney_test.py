import pandas as pd
import numpy as np
from scipy import stats
from typing import Dict
from pandas import DataFrame
from sklearn import preprocessing

def mannwhitney_u_test(df: DataFrame) -> Dict:
        
    column_list = df.columns.drop(["Community", "New_Community", "New_Community_Name"])

    result = {}

    for label in np.unique(df["New_Community_Name"].values):
        
        print(f"Community: {label}")
        
        df_1 = df[df["New_Community_Name"] == label]
        df_2 = df[df["New_Community_Name"] != label]
        
        label_df = DataFrame(columns=['col', 'mean_labels', 'mean_other', 'pvalue'])
        
        for col in column_list:

            stat, pvalue = stats.mannwhitneyu(df_1[col], df_2[col])

            new_row = DataFrame({
                "col": [col],
                "mean_labels": [df_1[col].mean()],
                "mean_other": [df_2[col].mean()],
                "pvalue": [pvalue]
            })
        
            label_df = pd.concat([label_df, new_row], ignore_index=True)
        
        label_df.sort_values(by=["pvalue"], inplace=True)
        result[label] = label_df
        
    return result

df = pd.read_csv("./Data/CSV/projects_tmp.csv")

columns_name=['acronym', 'status', 'title', 'startDate', 'endDate', 'totalCost',
       'ecMaxContribution', 'legalBasis', 'topics', 'ecSignatureDate',
       'frameworkProgramme', 'masterCall', 'subCall', 'fundingScheme',
       'nature', 'objective', 'contentUpdateDate', 'rcn', 'grantDoi']

for col in columns_name:
    df[str(col)] = df[str(col)].astype("category")

res = mannwhitney_u_test(df.drop(columns=['id', 'acronym', 'status', 'title', 'startDate', 'endDate', 'totalCost',
       'ecMaxContribution', 'legalBasis', 'topics', 'ecSignatureDate',
       'frameworkProgramme', 'masterCall', 'subCall', 'fundingScheme',
       'nature', 'objective', 'contentUpdateDate', 'rcn', 'grantDoi']))

print(res[0])