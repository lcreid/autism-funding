#Comments and Questions about Data Modeling
1. I tried using an open source data modeling tool.  Please look at it and try to determine if this is a viable tool.
You can find it at: [http://www.sqlpower.ca/page/architect](http://www.sqlpower.ca/page/architect).  I haven't looked at how
suitable this is for Linux, beyond noting that there is a download link for Unix/Generic.
2. I created a new folder called **docs** and I have saved the er model in that folder, along with a pdf version of the model.  We need
to think about version control if we keep the diagrams here.
3. As I began to create the data model, I began to ask myself some questions that I wish there was another voice around to answer.
  - Should Address and PhoneNumber be normalized into separate tables.
  - If we put PhoneNumber in a separate table, then the question arises as to how to relate PhoneNumber to other tables.  In the case
where a Parent may have multiple phone numbers, the PhoneNumber table would contain a parent\_id, which would be a foreign key back
to the Parent table.  There would be 0, 1 or many phone numbers for each Parent.  This works unless the FundedPerson can also have one or
more phone numbers.  If this is the case (and perhaps it should be so anyway) then we should not have separate Parent and FundedPerson tables - but a single Entity table, each entity having a entity\_type of 'parent', 'guardian', 'funded person', etc.
  - What is the proper way (and by proper I mean, the Larry way) to store phone numbers.  Storing as a single character string allows
for very flexible international phone numbers.  But I suspect that we really should only concern ourselves with North American numbers.
This means that we should have an area code (CHAR(3)), exchange (CHAR(3)), number (CHAR(4)) and extension (CHAR(5))  This would
be easier to check for completeness on entry.
  - There is, or course, the decision to be made on what geography we would accept in this.  Although this is aimed at BC residents in
the initial offering, I would think we may expand this to other provinces if interest is high enough.  I think we should accept US addresses as parents may be split up.
