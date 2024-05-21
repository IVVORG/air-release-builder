# air-release-builder

Allows to create RC/Release of 2 projects:
 - Airs-bp3 - backend part
 - BO - frontend part

In order to make RC/Release user has to modify file Modify.Me
It has the following structure:

```
version=RC/R
action=N/F
project=Front/Back/All
Date=30/10/2022 16:59
```

## Example:

1. To make Release Candidate of both projects BO and Airs-bp3 from current alpha:

```
version=RC
action=N
project=All
Date=01/11/2022 16:59
```

2. To make Release of both projects BO and Airs-bp3 from current Release Candidate:

```
version=R
action=N
project=All
Date=01/11/2022 16:59
```

If something fails during builidng process the Workflow finishes with exist code 1 (Error).
Full logs can be seen in github workflow track, in job "Make airs-bp3 release".


Note: Building process is intiated only if file Modify.Me is changed in a commit.

