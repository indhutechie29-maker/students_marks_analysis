import pandas as pd
df=pd.read_csv("students_analysis.csv")
print(df)

#display first 5 rows
print("first 5 rows")
print(df.head())

#display number of rows and column
print("\nshape of data")
print(df.shape)

#display columns name
print("\ncolumns names")
print(df.columns)

#display information about the dataset
print("\ndata information")
print(df.info())

subjects=["VLSI DESIGN","CCN","ES&IOT","ME","RES","CSD IV"]
for subject in subjects:
    df[subject]=pd.to_numeric(df[subject],errors="coerce")
print("\ndata types after conversion:")
print(df.dtypes)

#STUDENT WHO SCORED 50 OR ABOVE IN VLSI DESIGN
vlsi_students=df[df["VLSI DESIGN"]>=50]
print("\nstudents who scored 50 or above in vlsi design")
print(vlsi_students[["ROLL NO","NAME","VLSI DESIGN"]])

#STUDENTS WHO SCORED 50 OR ABOVE IN ALL SUBJECTS
passed_all=df[df[subjects].ge(50).all(axis=1)]
print("\nstudents who scored 50 or above in all the subject")
print(passed_all[["ROLL NO","NAME"]+subjects])

#STUDENTS WHO SCORED BELOW 50 IN AT LEAST ONE SUBJECT

failed_students=df[df[subjects].lt(50).any(axis=1)]
print("\nstudents who failed in at least one subject")
print(failed_students[["ROLL NO","NAME"]+subjects])

#calculate average marks for each student
df["AVERAGE"]=df[subjects].mean(axis=1)
print("\nstudent average marks")
print(df[["ROLL NO","NAME","AVERAGE"]])

#TOP 10 STUDENTS BASED ON AVERAGE
top_10=df.sort_values("AVERAGE",ascending=False).head(10)
print("\ntop 10 students")
print(top_10[["ROLL NO","NAME","AVERAGE"]])

#CALCULATE_AVERAGE MARKS FOR EACH SUBJECT
subject_average=df[subjects].mean()
print("\nsubject wise average marks:")
print(subject_average)

# Count students who passed all subjects
pass_count = len(passed_all)
# Count students who failed at least one subject
fail_count = len(failed_students)
print("\nPASS STUDENTS:", pass_count)
print("FAIL STUDENTS:", fail_count)
 
# Calculate pass and fail percentage
total_students = len(df)
pass_percentage = (pass_count / total_students) * 100
fail_percentage = (fail_count / total_students) * 100
print("\nPASS PERCENTAGE:", round(pass_percentage, 2), "%")
print("FAIL PERCENTAGE:", round(fail_percentage, 2), "%")

#subject pass count
print("\nsubject wise pass count")
for subject in subjects:
    count=(df[subjects]>=50).sum()
    print(subject,":",count)

#subject fail count
print("\nsubject wise pass count")
for subject in subjects:
    count=(df[subjects]<=50).sum()
    print(subject,":",count)

# Subject-wise pass percentage
print("\nSUBJECT-WISE PASS PERCENTAGE:")
for subject in subjects:
    pass_count = (df[subject] >= 50).sum()
    percentage = (pass_count / total_students) * 100
    print(subject, ":", round(percentage, 2), "%")

# Students who need improvement
improvement = df[df[subjects].lt(50).any(axis=1)]
print("\nSTUDENTS NEEDING IMPROVEMENT:")
print(improvement[["ROLL NO", "NAME"] + subjects])

# Number of failed subjects for each student
df["FAILED_SUBJECTS"] = df[subjects].lt(50).sum(axis=1)
print("\nFAILED SUBJECTS FOR EACH STUDENT:")
print(df[["ROLL NO", "NAME", "FAILED_SUBJECTS"]])

# Students who failed 2 or more subjects
high_risk = df[df["FAILED_SUBJECTS"] >= 2]
print("\nSTUDENTS WHO FAILED 2 OR MORE SUBJECTS:")
print(high_risk[["ROLL NO", "NAME", "FAILED_SUBJECTS"]])

#create student rank
df["RANK"]=df["AVERAGE"].rank(ascending=False,method="min")
df["RANK"]=df["RANK"].astype("Int64")
print("\nSTUDENT RANK")
print(df[["ROLL NO","NAME","AVERAGE","RANK"]].sort_values("RANK"))

bins = [0, 10, 20, 30, 40, 50, 60, 70, 80, 90, 101]
labels = [
"0-10",
"10-20",
"20-30",
"30-40",
"40-50",
"50-60",
"60-70",
"70-80",
"80-90",
"90-100"
]
print("\nMARK DISTRIBUTION FOR ALL SUBJECTS:")
for subject in subjects:
  mark_range = pd.cut(df[subject],bins=bins,labels=labels,right=False)
  count = mark_range.value_counts().sort_index()
  print("\n", subject)
for mark_range, number_of_students in count.items():
   print(mark_range, ":", number_of_students)

df.to_csv(
    "STUDENTS_ANALYSIS_RESULT.csv",
    index=False
)
print("\nANALYSIS COMPLETED SUCCESSFULLY!")
print("Result saved as STUDENTS_ANALYSIS_RESULT.csv")