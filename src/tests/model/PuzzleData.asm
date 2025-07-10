    module Puzzles

FIRST_ROUND:    equ 1
LAST_ROUND:     equ 3
LAST_LEVEL:     equ 10

;-----------------------------------------------------------------------------------
; 
; List: list of puzzle structs
; 
;-----------------------------------------------------------------------------------
list:
    puzzleStruct CAT_WORLD, world11
    puzzleStruct CAT_WORLD, world12
    puzzleStruct CAT_WORLD, world13

    puzzleStruct CAT_TV, tv11
    puzzleStruct CAT_TV, tv12
    puzzleStruct CAT_TV, tv13

    puzzleStruct CAT_SCIENCE, science11
    puzzleStruct CAT_SCIENCE, science12
    puzzleStruct CAT_SCIENCE, science13

    puzzleStruct CAT_GAMES, games11
    puzzleStruct CAT_GAMES, games12
    puzzleStruct CAT_GAMES, games13

    puzzleStruct CAT_MUSIC, music11
    puzzleStruct CAT_MUSIC, music12
    puzzleStruct CAT_MUSIC, music13

    puzzleStruct CAT_TECH, tech11
    puzzleStruct CAT_TECH, tech12
    puzzleStruct CAT_TECH, tech13

    puzzleStruct CAT_FILM, film11
    puzzleStruct CAT_FILM, film12
    puzzleStruct CAT_FILM, film13

    puzzleStruct CAT_FILM, film21
    puzzleStruct CAT_FILM, film22
    puzzleStruct CAT_FILM, film23

    puzzleStruct CAT_FILM, film31
    puzzleStruct CAT_FILM, film32
    puzzleStruct CAT_FILM, film33

    puzzleStruct CAT_PEOPLE, people11
    puzzleStruct CAT_PEOPLE, people12
    puzzleStruct CAT_PEOPLE, people13

    puzzleStruct CAT_HISTORY, history11
    puzzleStruct CAT_HISTORY, history12
    puzzleStruct CAT_HISTORY, history13
    
    puzzleStruct CAT_CULTURE, culture11
    puzzleStruct CAT_CULTURE, culture12
    puzzleStruct CAT_CULTURE, culture13
list_end:

;-----------------------------------------------------------------------------------
; 
; Data: Puzzle strings  [ptrLabel: db anagram,clue]
; 
;-----------------------------------------------------------------------------------

culture11: db "THE\nMONA LISA",0,"A little smile from Da Vinci",0
culture12: db "THE BIRTH\nOF VENUS",0,"A planet was born",0
culture13: db "THE\nPERSISTENCE\nOF MEMORY",0,"AKA The Melting Clocks",0

history11: db "BATTLE OF\nHASTINGS",0,"1066 and all that",0
history12: db "BATTLE OF\nAGINCOURT",0,"The longbowmen say up yours",0
history13: db "BATTLE OF\nBOSWORTH\nFIELD",0,"The last big fight over flowers",0

people11: db "ALBERT\nEINSTEIN",0,"1905 was his annus mirablis"
people12: db "ISAAC\nNEWTON",0,"Definitely a Spectrum guy"
people13: db "JOCELYN\nBELL",0,"Astronomer who found Little Green Men?"

film31: db "TIME\nBANDITS",0,"Stinking Kevin",0
film33: db "ZERO\nTHEOREM",0,"No idea",0
film32: db "JABBERWOCKY",0,"Nonsense returns Ykcowrebbaj",0

film21: db "THE IPCRESS\nFILE",0,"Mindbending spy thriller",0
film22: db "THE\nITALIAN\nJOB",0,"Blow the bloody doors off",0
film23: db "THE MAN\nWHO WOULD\nBE KING",0,"He maybe Rex",0

film11: db "CAPRICORN\nONE",0,"Astrological conspiracy",0
film12: db "THE\nPARALLAX\nVIEW",0,"Nice scrolling effect",0
film13: db "ALL THE\nPRESIDENTS\nMEN",0,"Not porn, but has deep throat",0

tech11: db "ATARI VCS",0,"2600",0
tech12: db "ACORN ATOM",0,"< Proton & Electron",0
tech13: db "SEGA\nDREAMCAST",0,"Windows CE Console",0

music11: db "DURAN\nDURAN",0,"And you are again?",0
music12: db "THE ACE\nOF SPADES",0,"The best shovel?",0
music13: db "SMELLS\nLIKE TEEN\nSPIRIT",0,"Whiffy adolescent ghost",0

games11: db "DONKEY\nKONG",0,"Mario's first",0
games12: db "JET SET\nWILLY",0,"A member of the mile high club?",0
games13: db "DOOM II\nHELL ON\nEARTH",0,"ID Unknown!",0

world11: db "TAJ\nMAHAL",0,"Marble Mausoleum",0
world12: db "EIFFEL\nTOWER",0,"A View To A Kill",0
world13: db "GREAT\nSPHINX\nOF GIZA",0,"Bomb Jack",0

tv11: db "BABYLON V",0,"Epic Sci-fi",0
tv12: db "BREAKING\nBAD",0,"Heisberg?",0
tv13: db "GAME OF\nTHRONES",0,"T*ts and Dragons",0

science11: db "BUNSEN\nBURNER",0,"Flamethrower?",0
science12: db "DRAKE\nEQUATION",0,"Where is everyone?",0
science13: db "QUANTUM\nMECHANICS",0,"Planck's Baby",0



    endmodule