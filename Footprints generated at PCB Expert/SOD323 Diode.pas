Var
    CurrentLib : IPCB_Library;

Procedure CreateSMDComponentPad(NewPCBLibComp : IPCB_LibComponent, Name : String, Layer : TLayer, X : Real, Y : Real, OffsetX : Real, OffsetY : Real,
                                TopShape : TShape, TopXSize : Real, TopYSize : Real, Rotation: Real, CRRatio : Real, PMExpansion : Real, SMExpansion : Real,
                                PMFromRules : Boolean, SMFromRules : Boolean);
Var
    NewPad                      : IPCB_Pad2;
    PadCache                    : TPadCache;

Begin
    NewPad := PcbServer.PCBObjectFactory(ePadObject, eNoDimension, eCreate_Default);
    NewPad.HoleSize := MMsToCoord(0);
    NewPad.Layer    := Layer;
    NewPad.TopShape := TopShape;
    if TopShape = eRoundedRectangular then
        NewPad.SetState_StackCRPctOnLayer(eTopLayer, CRRatio);
    NewPad.TopXSize := MMsToCoord(TopXSize);
    NewPad.TopYSize := MMsToCoord(TopYSize);
    NewPad.RotateBy(Rotation);
    NewPad.MoveToXY(MMsToCoord(X), MMsToCoord(Y));
    NewPad.Name := Name;

    Padcache := NewPad.GetState_Cache;
    if (PMExpansion <> 0) or (PMFromRules = False) then
    Begin
        Padcache.PasteMaskExpansionValid   := eCacheManual;
        Padcache.PasteMaskExpansion        := MMsToCoord(PMExpansion);
    End;
    if (SMExpansion <> 0) or (SMFromRules = False) then
    Begin
        Padcache.SolderMaskExpansionValid  := eCacheManual;
        Padcache.SolderMaskExpansion       := MMsToCoord(SMExpansion);
    End;
    NewPad.SetState_Cache              := Padcache;

    NewPCBLibComp.AddPCBObject(NewPad);
    PCBServer.SendMessageToRobots(NewPCBLibComp.I_ObjectAddress,c_Broadcast,PCBM_BoardRegisteration,NewPad.I_ObjectAddress);
End;

Procedure CreateComponentTrack(NewPCBLibComp : IPCB_LibComponent, X1 : Real, Y1 : Real, X2 : Real, Y2 : Real, Layer : TLayer, LineWidth : Real, IsKeepout : Boolean);
Var
    NewTrack                    : IPCB_Track;

Begin
    NewTrack := PcbServer.PCBObjectFactory(eTrackObject,eNoDimension,eCreate_Default);
    NewTrack.X1 := MMsToCoord(X1);
    NewTrack.Y1 := MMsToCoord(Y1);
    NewTrack.X2 := MMsToCoord(X2);
    NewTrack.Y2 := MMsToCoord(Y2);
    NewTrack.Layer := Layer;
    NewTrack.Width := MMsToCoord(LineWidth);
    NewTrack.IsKeepout := IsKeepout;
    NewPCBLibComp.AddPCBObject(NewTrack);
    PCBServer.SendMessageToRobots(NewPCBLibComp.I_ObjectAddress,c_Broadcast,PCBM_BoardRegisteration,NewTrack.I_ObjectAddress);
End;

Procedure CreateComponentArc(NewPCBLibComp : IPCB_LibComponent, CenterX : Real, CenterY: Real, Radius : Real, StartAngle : Real, EndAngle : Real, Layer : TLayer, LineWidth : Real, IsKeepout : Boolean);
Var
    NewArc                      : IPCB_Arc;

Begin
    NewArc := PCBServer.PCBObjectFactory(eArcObject,eNoDimension,eCreate_Default);
    NewArc.XCenter := MMsToCoord(CenterX);
    NewArc.YCenter := MMsToCoord(CenterY);
    NewArc.Radius := MMsToCoord(Radius);
    NewArc.StartAngle := StartAngle;
    NewArc.EndAngle := EndAngle;
    NewArc.Layer := Layer;
    NewArc.LineWidth := MMsToCoord(LineWidth);
    NewArc.IsKeepout := IsKeepout;
    NewPCBLibComp.AddPCBObject(NewArc);
    PCBServer.SendMessageToRobots(NewPCBLibComp.I_ObjectAddress,c_Broadcast,PCBM_BoardRegisteration,NewArc.I_ObjectAddress);
End;

Procedure CreateComponentSOD323 Diode(Zero : integer);
Var
    NewPCBLibComp               : IPCB_LibComponent;
    NewPad                      : IPCB_Pad2;
    NewRegion                   : IPCB_Region;
    NewContour                  : IPCB_Contour;
    STEPmodel                   : IPCB_ComponentBody;
    Model                       : IPCB_Model;

Begin
    Try
        PCBServer.PreProcess;

        NewPCBLibComp := PCBServer.CreatePCBLibComp;
        NewPcbLibComp.Name := 'SOD323 Diode';
        NewPCBLibComp.Description := 'Small Outline Diode (SOD); 1.70 mm L X 1.25 mm W X 1.00 mm H body';
        NewPCBLibComp.Height := MMsToCoord(1);

        CreateSMDComponentPad(NewPCBLibComp, 'C', eTopLayer, -0.905, 0, 0, 0, eRectangular, 0.72, 0.5, 180, 0, 0, 0, True, True);
        CreateSMDComponentPad(NewPCBLibComp, 'A', eTopLayer, 0.905, 0, 0, 0, eRectangular, 0.72, 0.5, 0, 0, 0, 0, True, True);

        CreateComponentTrack(NewPCBLibComp, -0.9, -0.68, -0.9, 0.68, eMechanical11, 0.12, False);
        CreateComponentTrack(NewPCBLibComp, -0.9, 0.68, 0.9, 0.68, eMechanical11, 0.12, False);
        CreateComponentTrack(NewPCBLibComp, 0.9, 0.68, 0.9, -0.68, eMechanical11, 0.12, False);
        CreateComponentTrack(NewPCBLibComp, 0.9, -0.68, -0.9, -0.68, eMechanical11, 0.12, False);
        CreateComponentTrack(NewPCBLibComp, -1.52, -0.93, -1.52, 0.93, eMechanical15, 0.05, False);
        CreateComponentTrack(NewPCBLibComp, -1.52, 0.93, 1.52, 0.93, eMechanical15, 0.05, False);
        CreateComponentTrack(NewPCBLibComp, 1.52, 0.93, 1.52, -0.93, eMechanical15, 0.05, False);
        CreateComponentTrack(NewPCBLibComp, 1.52, -0.93, -1.52, -0.93, eMechanical15, 0.05, False);
        CreateComponentArc(NewPCBLibComp, 0, 0, 0.25, 0, 360, eMechanical15, 0.05, False);
        CreateComponentTrack(NewPCBLibComp, 0.35, 0, -0.35, 0, eMechanical15, 0.05, False);
        CreateComponentTrack(NewPCBLibComp, 0, 0.35, 0, -0.35, eMechanical15, 0.05, False);
        CreateComponentTrack(NewPCBLibComp, 0.85, 0.68, -1.445, 0.68, eTopOverlay, 0.12, False);
        CreateComponentTrack(NewPCBLibComp, -1.445, 0.68, -1.445, -0.68, eTopOverlay, 0.12, False);
        CreateComponentTrack(NewPCBLibComp, -1.445, -0.68, 0.85, -0.68, eTopOverlay, 0.12, False);

        CurrentLib.RegisterComponent(NewPCBLibComp);
        CurrentLib.CurrentComponent := NewPcbLibComp;
    Finally
        PCBServer.PostProcess;
    End;

    CurrentLib.Board.ViewManager_FullUpdate;
    Client.SendMessage('PCB:Zoom', 'Action=All' , 255, Client.CurrentView)
End;

Procedure CreateALibrary;
Var
    View     : IServerDocumentView;
    Document : IServerDocument;

Begin
    If PCBServer = Nil Then
    Begin
        ShowMessage('No PCBServer present. This script inserts a footprint into an existing PCB Library that has the current focus.');
        Exit;
    End;

    CurrentLib := PcbServer.GetCurrentPCBLibrary;
    If CurrentLib = Nil Then
    Begin
        ShowMessage('You must have focus on a PCB Library in order for this script to run.');
        Exit;
    End;

    View := Client.GetCurrentView;
    Document := View.OwnerDocument;
    Document.Modified := True;

    CreateComponentSOD323 Diode(0);

End;

End.
