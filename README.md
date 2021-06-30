# Patent-5-year-citation-dataset-creation
Forward citation within 5 years since grant of (almost) all patents granted by USPTO up to 2021

For this project, citation level labels are created as follows.
1. From the patent dataset from PatentView, I extracted all the pairs of id of citing patent  and id of cited patent.
2. I attached the grant date to all of the citing patents and the cited patent. (I created a simple SQLite database (codes included in SQLiteatabase.py) to handle this and next step, due to memory limit).
3. For each cited patent, I create a new variable (maxdate) by adding 5 years to its grant date. Eliminate all its citing patents with grant date later than the maxdate. Then, I count all the remaining citing patents to get a raw within 5 year citation count.
4. I grouped the cited patent by the 3 digits CPC subsection code (technology class) that is listed first (CPC orders subsection code in decreasing order of importance, here I only take the subsection code listed first into account). Then I calculated citation count 99 and 90 percentile within each of the technology class.
5. Finally, those patents with raw count greater that the 99 percentile get labeled as top1pct. Those with count short of top1\% but greater than 90\%, get a top10pct label. Those with count of at least one but short of 90\% percentile get a btm90_lst1 label. Those without within 5 year citation has the zero_cite label.
6. Remove examples without full 5 year window to receive citation.
The labelling of citation level has no fixed rule. Different labeling strategies encapsulate different information about a given patent. The strategy I implemented mostly capture a patent's short to midterm impact within the field it contributes to. It is necessary to mention that my labelling strategy may not be a good indicator of a patent's long term impact, since a patent can still receive citation after 50 years of its issuance date. (Hall et al 2001)
The rest of data processing involve joining the dataset containing CPC subsection ids of patents to the table containing the title + abstraction text.
