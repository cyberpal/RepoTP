﻿CREATE ROLE [executor]
    AUTHORIZATION [dbo];


GO
ALTER ROLE [executor] ADD MEMBER [BANELCO\fscarpello];


GO
ALTER ROLE [executor] ADD MEMBER [VISA2\ESILESEQ];


GO
ALTER ROLE [executor] ADD MEMBER [BANELCO\ellopis];


GO
ALTER ROLE [executor] ADD MEMBER [VISA2\VSIFRSCA];


GO
ALTER ROLE [executor] ADD MEMBER [VISA2\ESIESDUE];


GO
ALTER ROLE [executor] ADD MEMBER [VISA2\ESIALBAR];


GO
ALTER ROLE [executor] ADD MEMBER [VISA2\ESIMADIA];

