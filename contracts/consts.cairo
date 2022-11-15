%lang starknet
from starkware.cairo.common.alloc import alloc

// Define a 12 note octave base
// For Microtonal mode definition, change the OCTAVEBASE and represent scales as intervallic ratios summing to OCTAVEBASE

const OCTAVEBASE = 12;
