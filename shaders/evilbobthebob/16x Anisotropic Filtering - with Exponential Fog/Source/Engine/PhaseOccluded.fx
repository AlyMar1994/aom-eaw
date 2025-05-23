///////////////////////////////////////////////////////////////////////////////////////////////////
// Petroglyph Confidential Source Code -- Do Not Distribute
///////////////////////////////////////////////////////////////////////////////////////////////////
//
//          $File: //depot/Projects/StarWars_Steam/FOC/Art/Shaders/Engine/PhaseOccluded.fx $
//          $Author: Brian_Hayes $
//          $DateTime: 2017/03/22 10:16:16 $
//          $Revision: #1 $
//
///////////////////////////////////////////////////////////////////////////////////////////////////
/*
	
	FX file for the Opaque render phase.  
	Pass 0 is applied before rendering all "opaque" render tasks.
	Pass 1 is aplied after rendering all opaque render tasks.

*/


#include "../AlamoEngine.fxh"


///////////////////////////////////////////////////////
//
// Techniques
//
///////////////////////////////////////////////////////
technique t0
<
	string LOD="FIXEDFUNCTION";	// minmum LOD
>
{
    pass t0_p0
    {
	}

	pass t0_p1
	{
        SB_START
    		ZWriteEnable = TRUE;
    		ZFunc = LESSEQUAL;
        SB_END
	}
}
