%lang starknet
from starkware.cairo.common.alloc import alloc

//*********************************************************************************************
//  Mode & Key Definitions
//
// We define Scales/Modes as an ordered array of ascending interval steps
//
// Example 1: [do, re, me, fa, sol, la, ti] in C Major Key -> C,D,E,F,G,A,B -> Modal Steps: [2,2,1,2,2,1]
//
// It is from these defined steps that we can compute a 'Key' AKA Pitches of a Mode at a given Note Base
//
// For microtonal scales, steps should be defined as ratios of BASEOCTAVE
//**********************************************************************************************

@view
func major_steps{}() -> (mode_len: felt, mode: felt*) {
    alloc_locals;

    let (local mode) = alloc();

    assert [mode + 0] = 2;
    assert [mode + 1] = 2;
    assert [mode + 2] = 1;
    assert [mode + 3] = 2;
    assert [mode + 4] = 2;
    assert [mode + 5] = 2;
    assert [mode + 6] = 1;

    let mode_len = 7;

    return (mode_len, mode);
}

@view
func minor_steps{}() -> (mode_len: felt, mode: felt*) {
    alloc_locals;

    let (local mode) = alloc();

    assert [mode + 0] = 2;
    assert [mode + 1] = 1;
    assert [mode + 2] = 2;
    assert [mode + 3] = 2;
    assert [mode + 4] = 2;
    assert [mode + 5] = 2;
    assert [mode + 6] = 2;

    let mode_len = 7;

    return (mode_len, mode);
}

@view
func lydian_steps{}() -> (mode_len: felt, mode: felt*) {
    alloc_locals;

    let (local mode) = alloc();

    assert [mode + 0] = 2;
    assert [mode + 1] = 2;
    assert [mode + 2] = 2;
    assert [mode + 3] = 1;
    assert [mode + 4] = 2;
    assert [mode + 5] = 2;
    assert [mode + 6] = 1;

    let mode_len = 7;

    return (mode_len, mode);
}

@view
func mixolydian_steps{}() -> (mode_len: felt, mode: felt*) {
    alloc_locals;

    let (local mode) = alloc();

    assert [mode + 0] = 2;
    assert [mode + 1] = 2;
    assert [mode + 2] = 1;
    assert [mode + 3] = 2;
    assert [mode + 4] = 2;
    assert [mode + 5] = 1;
    assert [mode + 6] = 2;

    let mode_len = 7;

    return (mode_len, mode);
}

@view
func dorian_steps{}() -> (mode_len: felt, mode: felt*) {
    alloc_locals;

    let (local mode) = alloc();

    assert [mode + 0] = 2;
    assert [mode + 1] = 1;
    assert [mode + 2] = 2;
    assert [mode + 3] = 2;
    assert [mode + 4] = 2;
    assert [mode + 5] = 1;
    assert [mode + 6] = 2;

    let mode_len = 7;

    return (mode_len, mode);
}

@view
func phrygian_steps{}() -> (mode_len: felt, mode: felt*) {
    alloc_locals;

    let (local mode) = alloc();

    assert [mode + 0] = 1;
    assert [mode + 1] = 2;
    assert [mode + 2] = 2;
    assert [mode + 3] = 2;
    assert [mode + 4] = 1;
    assert [mode + 5] = 2;
    assert [mode + 6] = 2;

    let mode_len = 7;

    return (mode_len, mode);
}

@view
func locrian_steps{}() -> (mode_len: felt, mode: felt*) {
    alloc_locals;

    let (local mode) = alloc();

    assert [mode + 0] = 1;
    assert [mode + 1] = 2;
    assert [mode + 2] = 2;
    assert [mode + 3] = 1;
    assert [mode + 4] = 2;
    assert [mode + 5] = 2;
    assert [mode + 6] = 2;

    let mode_len = 7;

    return (mode_len, mode);
}

@view
func aeolian_steps{}() -> (mode_len: felt, mode: felt*) {
    alloc_locals;

    let (local mode) = alloc();

    assert [mode + 0] = 2;
    assert [mode + 1] = 1;
    assert [mode + 2] = 2;
    assert [mode + 3] = 2;
    assert [mode + 4] = 2;
    assert [mode + 5] = 2;
    assert [mode + 6] = 2;

    let mode_len = 7;

    return (mode_len, mode);
}

@view
func harmonicminor_steps{}() -> (mode_len: felt, mode: felt*) {
    alloc_locals;

    let (local mode) = alloc();

    assert [mode + 0] = 2;
    assert [mode + 1] = 1;
    assert [mode + 2] = 2;
    assert [mode + 3] = 2;
    assert [mode + 4] = 1;
    assert [mode + 5] = 3;
    assert [mode + 6] = 1;

    let mode_len = 7;

    return (mode_len, mode);
}

@view
func naturalminor_steps{}() -> (mode_len: felt, mode: felt*) {
    alloc_locals;

    let (local mode) = alloc();

    assert [mode + 0] = 2;
    assert [mode + 1] = 1;
    assert [mode + 2] = 2;
    assert [mode + 3] = 2;
    assert [mode + 4] = 2;
    assert [mode + 5] = 2;
    assert [mode + 6] = 2;

    let mode_len = 7;

    return (mode_len, mode);
}

@view
func chromatic_steps{}() -> (mode_len: felt, mode: felt*) {
    alloc_locals;

    let (local mode) = alloc();

    assert [mode + 0] = 1;
    assert [mode + 1] = 1;
    assert [mode + 2] = 1;
    assert [mode + 3] = 1;
    assert [mode + 4] = 1;
    assert [mode + 5] = 1;
    assert [mode + 6] = 1;
    assert [mode + 7] = 1;
    assert [mode + 8] = 1;
    assert [mode + 9] = 1;
    assert [mode + 10] = 1;

    let mode_len = 11;

    return (mode_len, mode);
}

@view
func pentatonic_steps{}() -> (mode_len: felt, mode: felt*) {
    alloc_locals;

    let (local mode) = alloc();

    assert [mode + 0] = 2;
    assert [mode + 1] = 2;
    assert [mode + 2] = 3;
    assert [mode + 3] = 2;
    assert [mode + 4] = 3;
    let mode_len = 5;

    return (mode_len, mode);
}


//***************************************************************
// Indexed map to mode steps
// Helpful for Mapping to UIs/Clients and Modal Modulation
//***************************************************************

@view
func idx_to_mode_steps{range_check_ptr}(modeidx: felt) -> (mode_len: felt, mode: felt*) {
    alloc_locals;

    if (modeidx == 0) {
        let (local mode_len1, local mode1) = major_steps();
        return (mode_len1, mode1);
    }

    if (modeidx == 1) {
        let (local mode_len1, local mode1) = minor_steps();
        return (mode_len1, mode1);
    }

    if (modeidx == 2) {
        let (local mode_len1, local mode1) = dorian_steps();
        return (mode_len1, mode1);
    }

    if (modeidx == 3) {
        let (local mode_len1, local mode1) = lydian_steps();
        return (mode_len1, mode1);
    }

    if (modeidx == 4) {
        let (local mode_len1, local mode1) = mixolydian_steps();
        return (mode_len1, mode1);
    }

    if (modeidx == 5) {
        let (local mode_len1, local mode1) = phrygian_steps();
        return (mode_len1, mode1);
    }

    if (modeidx == 6) {
        let (local mode_len1, local mode1) = locrian_steps();
        return (mode_len1, mode1);
    }

    if (modeidx == 7) {
        let (local mode_len1, local mode1) = aeolian_steps();
        return (mode_len1, mode1);
    }

    if (modeidx == 8) {
        let (local mode_len1, local mode1) = harmonicminor_steps();
        return (mode_len1, mode1);
    }

    if (modeidx == 9) {
        let (local mode_len1, local mode1) = naturalminor_steps();
        return (mode_len1, mode1);
    }

    if (modeidx == 10) {
        let (local mode_len1, local mode1) = pentatonic_steps();
        return (mode_len1, mode1);
    }

    if (modeidx == 11) {
        let (local mode_len1, local mode1) = chromatic_steps();
        return (mode_len1, mode1);
    } else {
        let (local mode_len1, local mode1) = major_steps();
        return (mode_len1, mode1);
    }
}


