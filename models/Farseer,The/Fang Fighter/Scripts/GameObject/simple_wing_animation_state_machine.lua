require( "PGBase" )
require( "PGBaseDefinitions" )
require( "PGStateMachine" )

function Definitions()
    -- Kad 2017-09-20 - Adjust service rate to 1 check per second:
    ServiceRate = 1
    -- Kad 2017-09-20 - Define States:
    Define_State( "State_Init", State_Init )
    Define_State( "State_Idle", State_Idle )
    Define_State( "State_InCombat", State_InCombat )
    -- Kad 2017-09-20 - Define globals:
    _GDeployAnimation        = "deploy"
    _GDeployAnimationIndex   = 0
    _GUndeployAnimation      = "undeploy"
    _GUndeployAnimationIndex = 0
    _GMinInCombatTime        = 3.0
    _GMinOutOfCombatTime     = 3.0
end

function State_Init( message )
    if message == OnEnter then
        if Get_Game_Mode() ~= "Space" then
            ScriptExit()
        end
        Set_Next_State( "State_Idle" )
    end
end

function State_Idle( message )
    if message == OnEnter then
        Sleep( _GMinOutOfCombatTime )
    elseif message == OnUpdate then
        local InCombat = false
        if Object.Has_Attack_Target() then
            Set_Next_State( "State_InCombat" )
        end
    end
end

function State_InCombat( message )
    if message == OnEnter then
        Object.Play_Animation( _GDeployAnimation, false, _GDeployAnimationIndex )
        Sleep( _GMinInCombatTime )
    elseif message == OnUpdate then
        if not Object.Has_Attack_Target() then
            Set_Next_State( "State_Idle" )
        end
    elseif message == OnExit then
        Object.Play_Animation( _GUndeployAnimation, false, _GUndeployAnimationIndex )
    end
end
