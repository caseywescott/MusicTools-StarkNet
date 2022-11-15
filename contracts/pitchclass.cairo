%lang starknet
from starkware.cairo.common.alloc import alloc
from contracts.structs import (PitchClass, PitchInterval, CounterPointMetrics, MelodicMetrics, HarmonizerInputArgs)
from contracts.consts import (OCTAVEBASE)
from starkware.cairo.common.math_cmp import is_nn, is_le, is_not_zero
from starkware.cairo.common.math import unsigned_div_rem, assert_nn

//*****************************************************************************************************************
// PitchClass and Note Utils 
//
// Defintions:
// Note - Integer representation of pitches % OCTAVEBASE. Example E Major -> [1,3,4,6,8,9,11]  (C#,D#,E,F#,G#,A,B)
// Keynum - Integer representing MIDI note. Keynum = Note * (OCTAVEBASE * OctaveOfNote)
// Mode - Distances between adjacent notes within an OCTAVEBASE. Example: Major Key -> [2,2,1,2,2,2,1]
// Key  - A Mode transposed at a given pitch base
// Tonic - A Note transposing a Mode
// Modal Transposition - Moving up or down in pitch by a constant interval within a given mode
// Scale Degree - The position of a particular note on a scale relative to the tonic
//*****************************************************************************************************************

// Converts a PitchClass to a MIDI keynum

@view
func pc_to_keynum{range_check_ptr}(pclass: PitchClass) -> (keynum: felt) {
    return (keynum=pclass.note + (OCTAVEBASE * (pclass.octave + 1)));
}

//Compute the difference between two notes and the direction of that melodic motion
// Direction -> 0 == /oblique, 1 == /down, 2 == /up

@view
func diff_between_pc{range_check_ptr}(pclass1: PitchClass, pclass2: PitchClass) -> (
    steps: felt, direction: felt
) {
    alloc_locals;

    let keynum1 = pclass1.note + (OCTAVEBASE * (pclass1.octave + 1));
    let keynum2 = pclass2.note + (OCTAVEBASE * (pclass2.octave + 1));

    local direction = is_le(keynum1, keynum2);

    if ((keynum1 - keynum2) == 0) {
        return (0, 0);
    }

    if (direction == 1) {
        return (steps=keynum2 - keynum1, direction=direction + 1);
    } else {
        return (steps=keynum1 - keynum2, direction=direction + 1);
    }
}

//Provide Array, Compute and Return notes of mode at note base - note base is omitted

@view
func mode_notes_above_note_base{range_check_ptr}(
    arr_len: felt, arr: felt*, new_arr_len: felt, new_arr: felt*, note: felt
) {
    alloc_locals;

    if (arr_len == 0) {
        return ();
    }

    let (_, local newnote) = unsigned_div_rem(arr[0] + note, OCTAVEBASE);

    assert new_arr[new_arr_len] = newnote;

    mode_notes_above_note_base(
        arr_len=arr_len-1,
        arr=arr+1,
        new_arr_len=new_arr_len+1,
        new_arr=new_arr,
        note=newnote,
    );

    return ();
}

// Functions that compute collect notes of a mode at a specified pitch base in Normal Form (% OCTAVEBASE)
// Example: E Major -> [1,3,4,6,8,9,11]  (C#,D#,E,F#,G#,A,B)

@view
func get_notes_of_key{range_check_ptr}(tonic: felt, mode1_len: felt, mode1: felt*) -> (
    mode_len: felt, mode: felt*
) {
    alloc_locals;

    let (local new_arr: felt*) = alloc();

    let (_, local tonicnote) = unsigned_div_rem(tonic, OCTAVEBASE);

    assert new_arr[0] = tonicnote;

    mode_notes_above_note_base(mode1_len, mode1, 1, new_arr, tonic);

    return (mode_len=mode1_len, mode=new_arr);
}

// Compute the scale degree of MIDI keynum, given a tonic and mode

@view
func keynum_to_scale_degree{range_check_ptr}(
    tonic: felt, keynum: felt, mode2_len: felt, mode2: felt*
) -> (idx: felt) {
    alloc_locals;

    let (local new_arr: felt*) = alloc();

    let (mode_len1, mode1) = get_notes_of_key(tonic, mode2_len, mode2);

    let (_, local tonicnote) = unsigned_div_rem(tonic, OCTAVEBASE);
    let (_, local keynumnote) = unsigned_div_rem(keynum, OCTAVEBASE);

    let (idx) = get_scale_degree(mode_len1, mode1, 0, tonicnote, keynumnote);

    return (idx,);
}

// Compute the scale degree of a note given a key
// In this implementation, Scale degrees use zero-based counting, unlike in prevalent music theory literature          


@view
func get_scale_degree{range_check_ptr}(
    arr_len: felt, arr: felt*, arr_idx: felt, tonicnote: felt, keynumnote: felt
) -> (idx: felt) {
    alloc_locals;

    if (arr_idx == arr_len) {
        // get the nearest index
        return (idx=0);
    }

    if (keynumnote == arr[arr_idx]) {
        return (idx=arr_idx);
    }

    let (sum_of_rest) = get_scale_degree(
        arr_len=arr_len, arr=arr, arr_idx=arr_idx + 1, tonicnote=tonicnote, keynumnote=keynumnote
    );

    return (idx=sum_of_rest);
}

// Compute whether a note (0 <= note < OCTAVEBASE) is a scale degree of a given key

@view
func is_note_scale_degree{range_check_ptr}(
    notes_of_key_arr_len: felt, notes_of_key_arr: felt*, note: felt
) -> (bool: felt) {
    
    alloc_locals;

    if (notes_of_key_arr_len == 0) {
        // get the nearest index
        return (bool=0);
    }

    if (note == notes_of_key_arr[0]) {
        return (bool=1);
    }

    let (bool) = is_note_scale_degree(
        notes_of_key_arr_len=notes_of_key_arr_len-1, notes_of_key_arr=notes_of_key_arr+1, note=note
    );

    return (bool=bool);
}

// Compute whether a Keynum (0 <= note < 127) is a scale degree of a given key

@view
func is_keynum_scale_degree{range_check_ptr}(
    mode_steps_arr_len: felt, mode_steps_arr: felt*, keynumnote: felt
) -> (bool: felt) {

    alloc_locals;

    let (_, local tonicnote) = unsigned_div_rem(keynumnote, OCTAVEBASE);
    let (local arr_len, local arr) = get_notes_of_key(tonicnote, mode_steps_arr_len, mode_steps_arr);

    let (is_in_scale) = is_note_scale_degree(arr_len, arr, tonicnote);

    return (bool=is_in_scale);
}

@view
func is_every_keynum_in_array_scale_degree{range_check_ptr}(
    arr_len: felt, arr: felt*, mode_len: felt, mode: felt*, tonic: felt
) -> (bool: felt) {
    
    alloc_locals;

   // If iteration gets to end of list, then all elements are scale degree!
    if (arr_len == 0) {
        // get the nearest index
        return (bool=1);
    }

    let (scale_deg_bool) = is_keynum_scale_degree(mode_len, mode, arr[0]);
    //if element isn't a scale degree, return 0
    if (scale_deg_bool == 0) {
        return (bool=0);
    }

    let (bool) = is_every_keynum_in_array_scale_degree(
        arr_len=arr_len-1, arr=arr+1, mode_len=mode_len, mode=mode, tonic=tonic
    );

    return (bool=bool);
}

//********************
// Modal Transpostion 
//********************

// In order to compute modal transposition of a note given a mode and stepnum, one must calculate the distance of the transposition in steps from a given scale degree
// Example: transposing the note D in the key of C major by 2 steps is F. The distance of that transposition == 4 steps

@view
func recurse_modal_steps_and_sum2{range_check_ptr}(
    arr_len: felt, arr: felt*, start_scale_degree: felt, scale_steps: felt, stepsum: felt, direction: felt
) -> (numsteps: felt) {
    alloc_locals;

    if (scale_steps == 0) {
        return (numsteps=stepsum);
    }

    let (_, local new_idx) = unsigned_div_rem(start_scale_degree + 1, arr_len);

    let val = arr[new_idx];
    
    // if start_scale_degree = 0 set to arr_len-1, else

    let (sum_of_rest) = recurse_modal_steps_and_sum2(
        arr_len=arr_len,
        arr=arr,
        start_scale_degree=start_scale_degree+1,
        scale_steps=scale_steps-1,
        stepsum=stepsum + val,
        direction=direction
    );

    return (numsteps=sum_of_rest);
}

@view
func recurse_modal_steps_and_sum{range_check_ptr}(
    arr_len: felt, arr: felt*, start_scale_degree: felt, scale_steps: felt, stepsum: felt, inc: felt
) -> (numsteps: felt) {
    alloc_locals;

    if (inc == scale_steps) {
        return (numsteps=stepsum);
    }

    let (_, local new_idx) = unsigned_div_rem(start_scale_degree + inc, arr_len);

    let val = arr[new_idx];

    let (sum_of_rest) = recurse_modal_steps_and_sum(
        arr_len=arr_len,
        arr=arr,
        start_scale_degree=start_scale_degree,
        scale_steps=scale_steps,
        stepsum=stepsum + val,
        inc=inc + 1,
    );

    return (numsteps=sum_of_rest);
}

@view
func modal_transposition_inner{range_check_ptr}(
    start_scale_degree: felt, scale_steps: felt, mode_len: felt, mode: felt*
) -> (numsteps: felt) {
    alloc_locals;

    // let (mode_len, mode) = dorian_steps()

    let (_, local new_idx) = unsigned_div_rem(start_scale_degree, mode_len);

    let stepsum = 0;
    let increment = 0;

    let (steps) = recurse_modal_steps_and_sum(mode_len, mode, new_idx, scale_steps, stepsum, increment);

    return (numsteps=steps);
}

@view
func modal_transposition{range_check_ptr}(
    keynum: felt, scale_steps: felt, tonic: felt, mode_len: felt, mode: felt*
) -> (new_keynum: felt) {
    alloc_locals;

    // let (mode_len, mode) = dorian_steps()
    // let tonic = 2

    // tonic: felt, keynum: felt, mode2_len: felt, mode2: felt*
    let (start_scale_degree) = keynum_to_scale_degree(tonic, keynum, mode_len, mode);

    // start_scale_degree: felt, scale_steps: felt, mode_len: felt, mode: felt*
    let (steps) = modal_transposition_inner(start_scale_degree, scale_steps, mode_len, mode);

    let out = keynum + steps;
    return (new_keynum=out);
}

//**********************************
// Modal transposition below a note 
//**********************************

@view
func recurse_modal_steps_and_sum_descend{range_check_ptr}(
    arr_len: felt,
    arr: felt*,
    start_scale_degree: felt,
    scale_steps: felt,
    stepsum: felt,
    inc: felt,
    inc2: felt,
) -> (numsteps: felt) {
    alloc_locals;

    if (inc2 == scale_steps) {
        return (numsteps=stepsum);
    }

    if (inc == 0) {
        tempvar new_idx = arr_len - 1;
    } else {
        tempvar new_idx = inc - 1;
    }

    let val = arr[new_idx];

    let (sum_of_rest) = recurse_modal_steps_and_sum_descend(
        arr_len=arr_len,
        arr=arr,
        start_scale_degree=start_scale_degree,
        scale_steps=scale_steps,
        stepsum=stepsum + val,
        inc=new_idx,
        inc2=inc2 + 1,
    );

    return (numsteps=sum_of_rest);
}

@view
func modal_transposition_descend_inner{range_check_ptr}(
    start_scale_degree: felt, scale_steps: felt, mode_len: felt, mode: felt*
) -> (numsteps: felt) {
    alloc_locals;

    // let (mode_len, mode) = dorian_steps()

    let (_, local new_idx) = unsigned_div_rem(start_scale_degree, mode_len);

    let stepsum = 0;

    let (steps) = recurse_modal_steps_and_sum_descend(
        mode_len, mode, new_idx, scale_steps, stepsum, start_scale_degree, 0
    );

    return (numsteps=steps);
}

@view
func modal_transposition_descend{range_check_ptr}(
    keynum: felt, scale_steps: felt, tonic: felt, mode_len: felt, mode: felt*
) -> (new_keynum: felt) {
    alloc_locals;

    // let (mode_len, mode) = dorian_steps()
    // let tonic = 2

    // tonic: felt, keynum: felt, mode2_len: felt, mode2: felt*
    let (start_scale_degree) = keynum_to_scale_degree(tonic, keynum, mode_len, mode);

    // start_scale_degree: felt, scale_steps: felt, mode_len: felt, mode: felt*
    let (steps) = modal_transposition_descend_inner(start_scale_degree, scale_steps, mode_len, mode);

    let out = keynum - steps;
    return (new_keynum=out);
}

//direction 0 -> up, 1 -> down
@view
func modal_transposition_binary{range_check_ptr}(
    keynum: felt, scale_steps: felt, tonic: felt, direction: felt, mode_len: felt, mode: felt*
) -> (new_keynum: felt) {
    alloc_locals;

    // let (mode_len, mode) = dorian_steps()
    // let tonic = 2
    let (start_scale_degree) = keynum_to_scale_degree(tonic, keynum, mode_len, mode);

    // tonic: felt, keynum: felt, mode2_len: felt, mode2: felt*
if (direction == 0) {

   let (out) = modal_transposition(keynum, scale_steps, tonic, mode_len, mode);

    return (new_keynum=out);
    } 
    
    if (direction == 1) {
     let  (out) = modal_transposition_descend(keynum, scale_steps, tonic, mode_len, mode);

    return (new_keynum=out);
    }


    return (new_keynum=1);
   
}

//*******************************************************************
// Note Inversion
// basenote = V
// note_to_be_inverted = X
// V + (X-V) -> basenote + (note_to_be_inverted-basenote)
//
//*******************************************************************

@view
func invert_keynum{range_check_ptr}(
    basenote: felt, note: felt
) -> (inverted_keynum: felt) {
    
    alloc_locals;

    let inverted_keynum = (basenote + (basenote - note));
   
    return (inverted_keynum=inverted_keynum);
}



