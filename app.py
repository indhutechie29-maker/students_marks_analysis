
import streamlit as st
import pandas as pd
import plotly.express as px

# PAGE CONFIG
st.set_page_config(
    page_title="Student Marks Dashboard",
    page_icon="🎓",
    layout="wide"
)

st.title("🎓 STUDENT PERFORMANCE ANALYSIS")
st.markdown("### Academic Performance | Marks Analysis | Student Insights")
st.divider()

# SUBJECTS
subjects = [
    "VLSI DESIGN", "CCN", "ES&IOT",
    "ME", "RES", "CSD IV"
]

# LOAD DATA
@st.cache_data
def load_data():
    df = pd.read_csv("students_analysis.csv")

    df.columns = df.columns.str.strip()
    df["ROLL NO"] = df["ROLL NO"].astype(str)
    df["NAME"] = df["NAME"].astype(str).str.strip()

    for subject in subjects:
        df[subject] = pd.to_numeric(
            df[subject], errors="coerce"
        )

    df = df.dropna(subset=subjects, how="all").copy()

    df["AVERAGE"] = df[subjects].mean(axis=1)
    df["FAILED_SUBJECTS"] = df[subjects].lt(50).sum(axis=1)

    df["RESULT"] = df[subjects].ge(50).all(axis=1).map(
        {True: "Pass", False: "Fail"}
    )

    df["RANK"] = df["AVERAGE"].rank(
        ascending=False, method="min"
    ).astype(int)

    return df


try:
    df = load_data()
except Exception as e:
    st.error(f"Unable to load dataset: {e}")
    st.info(
        "Place students_analysis.csv in the same folder as app.py."
    )
    st.stop()

if df.empty:
    st.warning("No student records found.")
    st.stop()

# SIDEBAR FILTERS
st.sidebar.title("🔍 Filters")

selected_subject = st.sidebar.selectbox(
    "Select Subject",
    subjects
)

selected_result = st.sidebar.multiselect(
    "Select Result",
    ["Pass", "Fail"],
    default=["Pass", "Fail"]
)

filtered_df = df[df["RESULT"].isin(selected_result)].copy()

if filtered_df.empty:
    st.warning("No students found for selected filters.")
    st.stop()

# KPI CALCULATIONS
total_students = len(filtered_df)
average_marks = filtered_df["AVERAGE"].mean()
pass_count = (filtered_df["RESULT"] == "Pass").sum()
fail_count = (filtered_df["RESULT"] == "Fail").sum()

pass_percentage = (
    pass_count / total_students * 100
)

# KPI CARDS
st.subheader("📌 Key Performance Indicators")

c1, c2, c3, c4 = st.columns(4)

c1.metric("👨‍🎓 Total Students", total_students)
c2.metric("📊 Average Marks", f"{average_marks:.2f}")
c3.metric("✅ Pass Percentage", f"{pass_percentage:.2f}%")
c4.metric("❌ Failed Students", fail_count)

st.divider()

# PASS AND FAIL ANALYSIS
st.subheader("📈 Pass vs Fail Analysis")

col1, col2 = st.columns(2)

with col1:
    result_data = filtered_df["RESULT"].value_counts().reset_index()
    result_data.columns = ["Result", "Students"]

    fig = px.pie(
        result_data,
        names="Result",
        values="Students",
        hole=0.45,
        title="Student Pass and Fail Distribution"
    )
    st.plotly_chart(fig, use_container_width=True)

with col2:
    subject_results = pd.DataFrame({
        "Subject": subjects,
        "Passed": [
            (filtered_df[s] >= 50).sum() for s in subjects
        ],
        "Failed": [
            (filtered_df[s] < 50).sum() for s in subjects
        ]
    })

    fig = px.bar(
        subject_results,
        x="Subject",
        y=["Passed", "Failed"],
        barmode="group",
        title="Subject-wise Pass and Fail Count"
    )
    st.plotly_chart(fig, use_container_width=True)

# SUBJECT AVERAGE
st.subheader("📚 Subject-wise Average Marks")

subject_avg = pd.DataFrame({
    "Subject": subjects,
    "Average Marks": [
        filtered_df[s].mean() for s in subjects
    ]
})

fig = px.bar(
    subject_avg,
    x="Subject",
    y="Average Marks",
    color="Subject",
    text_auto=".2f",
    title="Average Marks by Subject"
)

fig.add_hline(
    y=50,
    line_dash="dash",
    annotation_text="Pass Mark (50)"
)

st.plotly_chart(fig, use_container_width=True)

# MARKS RANGE ANALYSIS
st.subheader("📊 Marks Range Analysis")

ranges = [0, 10, 20, 30, 40, 50, 60, 70, 80, 90, 101]

labels = [
    "0-9", "10-19", "20-29", "30-39", "40-49",
    "50-59", "60-69", "70-79", "80-89", "90-100"
]

range_data = pd.cut(
    filtered_df[selected_subject],
    bins=ranges,
    labels=labels,
    right=False
).value_counts().sort_index().reset_index()

range_data.columns = ["Marks Range", "Students"]

fig = px.bar(
    range_data,
    x="Marks Range",
    y="Students",
    color="Students",
    title=f"{selected_subject} - Marks Distribution",
    text="Students"
)

st.plotly_chart(fig, use_container_width=True)

# TOP 10 STUDENTS
st.subheader("🏆 Top 10 Students")

top_students = filtered_df.sort_values(
    "AVERAGE", ascending=False
).head(10)

st.dataframe(
    top_students[
        ["RANK", "ROLL NO", "NAME", "AVERAGE", "RESULT"]
    ],
    use_container_width=True,
    hide_index=True
)

# STUDENT PERFORMANCE TABLE
st.subheader("📋 Complete Student Performance")

search = st.text_input("Search Student by Name or Roll Number")

display_df = filtered_df.copy()

if search:
    display_df = display_df[
        display_df["NAME"].str.contains(
            search, case=False, na=False
        ) |
        display_df["ROLL NO"].str.contains(
            search, case=False, na=False
        )
    ]

st.dataframe(
    display_df[
        ["ROLL NO", "NAME"] + subjects +
        ["AVERAGE", "FAILED_SUBJECTS", "RANK", "RESULT"]
    ].sort_values("RANK"),
    use_container_width=True,
    hide_index=True
)

# DOWNLOAD REPORT
csv = display_df.to_csv(index=False).encode("utf-8")

st.download_button(
    "📥 Download Student Report",
    data=csv,
    file_name="student_performance_report.csv",
    mime="text/csv"
)

st.divider()
st.markdown(
    "**Developed using Python | Pandas | Streamlit | Plotly**"
)
