mkdir c:\temp\test2, c:\temp\test1 |out-null
Out-File c:\temp\test1\pew
if ((get-childitem c:\temp\test1\p*w) -or (get-childitem c:\temp\test2\p*w)) {"true story"} else {"awwCrapz"}
#true story
del c:\temp\test1\pew
if ((get-childitem c:\temp\test1\p*w) -or (get-childitem c:\temp\test2\p*w)) {"true story"} else {"awwCrapz"}
#awwCrapz
