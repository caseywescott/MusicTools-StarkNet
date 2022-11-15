%lang starknet

//*************************************************************************
// Pitch and Interval Structs 
//
// PitchClass: Used to Calculate Keynums. Pitch Class Keynums can be 0-127
// Example: MIDI Keynum 69 == A440 
//
// Notes are values from 0 <= note < OCTAVEBASE and increment
// Example: If OCTAVEBASE = 12, [C -> 0, C# -> 1, D -> 2...B-> 11]
// Example 2: MIDI Keynum 69: Note = 9, Octave = 5
//*************************************************************************

struct PitchClass {
    note: felt,
    octave: felt,
}

struct PitchInterval {
    quality: felt,
    size: felt,
}

//**************************************************************************
// Melodic and Harmonic Metric Structs
// Structs for managing voice leading properties of musical passages
// Needs integration to complete auto-harmonization algos
//**************************************************************************

struct CounterPointMetrics {
    count: felt,
    numvoices: felt,
    parallel_octave_count: felt,
    parallel_fifths: felt,
    parallel_fourths: felt,
    tritone_in_lowest_voice: felt,
    tritone_count: felt,
    //hidden_octave_count: felt,
    //hidden_fifths: felt,
    //hidden_fourths: felt,
    //consecutive_perfect_intervals: felt,
    //hidden_perfect_intervals: felt,
    harmonic_repetition_count: felt,
    span_between_lowest_and_highest_note: felt,
    is_dominant_chord: felt,
    //is_dominant_resolution: felt,
    contrapuntal_index: felt,
    harmonic_distance: felt,
}

struct MelodicMetrics {
    count: felt,
    unpermitted_melodic_intervals: felt,
    melodic_leaps: felt,
    melodic_tritone_outlines: felt,
    skips_in_same_direction: felt,
    skips_in_same_direction_second_leap_shorter: felt,
    repeated_notes_in_same_voice: felt,
    melodic_probability_index: felt,
    minimum_melodic_span: felt,
    //has_climax_note: felt,
}

//*****************************************
// Harmonizer User Input Argument Struct 
// Used to pass UI/Client args to contracts
//*****************************************

struct HarmonizerInputArgs {
    algorithm_idx: felt,
    tonic_idx: felt,
    pitchcollection_idx: felt,
    harmonies_val: felt,
    inversion_val: felt,
    spread_val: felt,
    last_note_data_idx: felt,
    num_divisions: felt,
}

