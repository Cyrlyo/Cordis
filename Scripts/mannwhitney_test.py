import pandas as pd
import numpy as np
from scipy import stats
from typing import Dict
from pandas import DataFrame
from sklearn import preprocessing

def mannwhitney_u_test(df: DataFrame) -> Dict:
        
    column_list = df.columns.drop(["Community", "New_Community", "New_Community_Name"])

    result = {}

    for label in np.sort(np.unique(df["New_Community_Name"].values)):
        
        print(f"Community: {label}")
        
        df_1 = df[df["New_Community_Name"] == label]
        df_2= df[df["New_Community_Name"] != label]
        
        label_df = DataFrame(columns=['col', 'mean_labels', 'mean_other', 'pvalue'])
        
        for col in column_list:
            
            stat = [stats.mannwhitneyu(df_1[col], df_2[col])]
            pvalue = np.mean([x.pvalue for x in stat])

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
