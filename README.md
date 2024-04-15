# chez
A Chess engine in Zig


## Ideas:

- We could do some move generation stuff with enums
    - Issue with moves outside of the board, would require additional bit
    - Unclear if add/subtract would give any advantage. 
- bb module as a struct:
    - Unlikely to be commensurable with packed...