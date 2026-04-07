--creating BIO table to import data from csv
CREATE TABLE BIO(
subject INTEGER PRIMARY KEY,
Age INTEGER,
Gender TEXT,
BMI NUMERIC,
"Body weight" NUMERIC,
Height NUMERIC,
"Self-identify" VARCHAR(250),
"A1c PDL (Lab)" NUMERIC,
"Fasting GLU - PDL (Lab)" NUMERIC,
Insulin NUMERIC,
Triglycerides NUMERIC,
Cholesterol NUMERIC,
HDL NUMERIC,
"Non HDL" NUMERIC,
"LDL (Cal)" NUMERIC,
"VLDL (Cal)" NUMERIC,
"Cho/HDL Ratio" NUMERIC,
"Collection time PDL (Lab)" VARCHAR(250),
"#1 Contour Fingerstick GLU" NUMERIC,
Time_GLU1 TIME,
"#2 Contour Fingerstick GLU" NUMERIC,
Time_GLU2 TIME,
"#3 Contour Fingerstick GLU" NUMERIC,
Time_GLU3 TIME
);

--DROP TABLE BIO 

--displaying data in BIO
SELECT * FROM BIO

--Renaming the columns
ALTER TABLE bio
RENAME COLUMN "Self-identify" TO race;

ALTER TABLE bio
RENAME COLUMN "Body weight" TO weight;

ALTER TABLE bio
RENAME COLUMN "A1c PDL (Lab)" TO HbA1c;

ALTER TABLE bio
RENAME COLUMN "Fasting GLU - PDL (Lab)" TO Fasting_glucose;

ALTER TABLE bio
RENAME COLUMN hdl TO "HDL";

ALTER TABLE bio
RENAME COLUMN "LDL (Cal)" TO "LDL";

ALTER TABLE bio
RENAME COLUMN "VLDL (Cal)" TO "VLDL";

ALTER TABLE bio
RENAME COLUMN "Collection time PDL (Lab)" TO Collection_time;

ALTER TABLE bio
RENAME COLUMN "#1 Contour Fingerstick GLU" TO Contour_glucose_measurement1;

ALTER TABLE bio
RENAME COlUMN time_glu1 TO time_glucose_measurement1;

ALTER TABLE bio
RENAME COlUMN "#2 Contour Fingerstick GLU" TO contour_glucose_measurement2;

ALTER TABLE bio
RENAME COlUMN time_glu2 TO time_glucose_measurement2;

ALTER TABLE bio
RENAME COlUMN "#3 Contour Fingerstick GLU" TO contour_glucose_measurement3;

ALTER TABLE bio
RENAME COlUMN time_glu3 TO time_glucose_measurement3;

--Rounding off the BMI VALUES
UPDATE bio
SET bmi = ROUND(bmi, 2);

--Extracting AM from the values of collection_time and changing the datatype from VARCHAR to Time
ALTER TABLE bio
ALTER COLUMN collection_time TYPE TIME
USING SPLIT_PART(collection_time, ' ', 1)::TIME;

--creating a new column bmi_category
ALTER TABLE bio
ADD COLUMN bmi_category TEXT;

--adding the values in the bmi_category
UPDATE bio
SET bmi_category = CASE 
						WHEN bmi < 18.5 THEN 'Underweight'
						WHEN bmi >= 18.5 AND bmi < 25 THEN 'Healthy Weight'
						WHEN bmi >=25 AND bmi < 30 THEN 'Overweight'
						WHEN bmi >= 30 THEN 'Obese'
						ELSE NULL
					END;
						
--creating a new column hbA1c category
ALTER TABLE bio
ADD COLUMN hbA1c_category TEXT;

--adding the values in hbA1c category
UPDATE bio
SET hbA1c_category = CASE 
						WHEN hba1c < 5.7 THEN 'Normal'
						WHEN hba1c >= 5.7 AND hba1c <= 6.4 THEN 'Prediabeties'
						WHEN hba1c > 6.4 THEN 'Diabeties'
						ELSE NULL
					END;

--creating a new column fasting_glucose category
ALTER TABLE bio
ADD COLUMN fasting_glucose_category TEXT;	

--adding the values in fasting_glucose category
UPDATE bio
SET fasting_glucose_category= CASE 
								  WHEN fasting_glucose >= 70 AND fasting_glucose <= 100 THEN 'Normal'
								  WHEN fasting_glucose > 100 AND fasting_glucose <= 125 THEN 'Prediabeties'
								  WHEN fasting_glucose > 125 THEN 'Diabeties'
								  WHEN fasting_glucose < 70 THEN 'Hyperglycemia'
								  ELSE NULL
								 END;


--creating a new column tryglycerides category
ALTER TABLE bio
ADD COLUMN triglycerides_category TEXT;	

--adding the vaues to the column tryglycerides category
UPDATE bio
SET triglycerides_category = CASE 
								WHEN triglycerides < 150 THEN 'Normal'
								WHEN triglycerides >= 150 AND triglycerides < 200 THEN 'Borderline High'
								WHEN triglycerides >= 200 AND triglycerides < 500 THEN 'High'
								WHEN triglycerides >= 500 THEN 'Very High'
								ELSE NULL
							END;

									
--creating a new column cholesterol category
ALTER TABLE bio
ADD COLUMN cholesterol_category TEXT;

--ADding the values to column cholesterol_category
UPDATE bio
SET cholesterol_category = CASE 
								WHEN cholesterol < 200 THEN 'Desirable'
								WHEN cholesterol >= 200 AND cholesterol <= 239 THEN 'Borderline High'
								WHEN cholesterol > 239 THEN 'High'
								ELSE NULL
							END;

--creating a new column HDL_category
ALTER TABLE bio
ADD COLUMN HDL_category TEXT;

--adding the values in the column HDL_category
UPDATE bio
SET hdl_category = CASE 
						WHEN gender = 'M' AND "HDL" >= 40 THEN 'Ideal HDL'
						WHEN gender = 'M' AND "HDL" < 40 THEN 'Low HDL'
						WHEN gender = 'F' AND "HDL" >= 50 THEN 'Ideal HDL'
						WHEN gender = 'F' AND "HDL" < 50 THEN 'Low HDL'
						ELSE NULL
					END;
					
--creating a new column LDL_category
ALTER TABLE bio
ADD COLUMN LDL_category TEXT;

--adding the values in the column LDL_category
UPDATE bio
SET	ldl_category = 	CASE 
						WHEN "LDL" < 100 THEN 'Optimal'
						WHEN "LDL" >= 100 AND "LDL" < 130 THEN  'Above Optimal'
						WHEN "LDL" >= 130 AND "LDL" < 160 THEN  'Borderline High'
						WHEN "LDL" >= 160 AND "LDL" < 190 THEN  'High'
						WHEN "LDL" >= 190 THEN 'High'
						ELSE NULL
					END;

--LDL has a value of 800 for the subject 12, which is an error or outlier. so updating the value with calculation.
UPDATE bio
SET "LDL" = NULL --FLOOR(cholesterol - "HDL" - (triglycerides/5)) is giving a negative value due to very high Triglyscerides, which is not valid so keeping it null
WHERE subject = 12;

--VLDL has a value of 400 fro the subject 12, which is an error or outlier, so updating the value with calculation.
UPDATE bio
SET "VLDL" = FLOOR(triglycerides/5)
WHERE subject = 12;

--updating the cho/HDL Ration for subject 12 as 400  is an error VALUE
UPDATE bio
SET "Cho/HDL Ratio"= ROUND(cholesterol/"HDL", 1)
WHERE subject = 12;


SELECT * FROM bio
WHERE hba1c_category = 'Prediabeties'
