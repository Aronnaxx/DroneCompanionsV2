@addField(VehicleObject)
let DCOFrontLeftTaken:Bool;

@addField(VehicleObject)
let DCOFrontRightTaken:Bool;

@addField(VehicleObject)
let DCOBackLeftTaken:Bool;

@addField(VehicleObject)
let DCOBackRightTaken:Bool;

@addField(CompanionSystem)
let DCOPlayerVehicles: array<wref<VehicleObject>>;

@wrapMethod(AISubActionMountVehicle_Record_Implementation)
 public final static func MountVehicle(context: ScriptExecutionContext, record: wref<AISubActionMountVehicle_Record>) -> Bool {

	//If it's not one of our drones, dont edit
	if !TweakDBInterface.GetCharacterRecord(ScriptExecutionContext.GetOwner(context).GetRecordID()).TagsContains(n"Robot"){
		return wrappedMethod(context, record);
	}
	

    let evt: ref<MountAIEvent>;
    let mountData: ref<MountEventData>;
    let slotName: CName;
    let vehicle: wref<VehicleObject>;
	let gi: GameInstance = ScriptExecutionContext.GetOwner(context).GetGame();
	
	if GameInstance.GetBlackboardSystem(gi).GetLocalInstanced(GetPlayer(gi).GetEntityID(), GetAllBlackboardDefs().PlayerStateMachine).GetInt(GetAllBlackboardDefs().PlayerStateMachine.SceneTier) >1{
		return false;
	};
	
    if !AIActionTarget.GetVehicleObject(context, record.Vehicle(), vehicle) {
		//LogChannel(n"DEBUG", "No vehicle to get");
      return false;
    };

	/*
    slotName = record.Slot().SeatName();
    if IsNameValid(slotName) {
      if VehicleComponent.IsSlotAvailable(ScriptExecutionContext.GetOwner(context).GetGame(), vehicle, slotName) {
	  		////LogChannel(n"DEBUG", "Slot we didnt use says fuck you");

        return false;
      };
    } else {
      //if !AIHumanComponent.GetLastUsedVehicleSlot(ScriptExecutionContext.GetOwner(context) as ScriptedPuppet, slotName) {
        slotName = n"";
      //};
      if !IsNameValid(slotName) || !VehicleComponent.IsSlotAvailable(ScriptExecutionContext.GetOwner(context).GetGame(), vehicle, slotName) {
        if !VehicleComponent.GetFirstAvailableSlot(ScriptExecutionContext.GetOwner(context).GetGame(), vehicle, slotName) {
			////LogChannel(n"DEBUG", "No first available slot");
          //return false;
		  slotName = n"seat_front_right";
        };
      };
    };
	*/
    if vehicle.IsDestroyed() {
		////LogChannel(n"DEBUG", "Vehicle destroyed what???");
      return false;
    };
	let DCOFoundSeat: Bool;
	////LogChannel(n"DEBUG", ToString(vehicle.DCOFrontRightTaken) + " " + ToString(vehicle.DCOBackLeftTaken) + " " + ToString(vehicle.DCOBackRightTaken));
	//LogChannel(n"DEBUG", "Iterating through DCO seats");
	//Check for if the seats been taken
	
    let seats: array<wref<VehicleSeat_Record>>;
    if !VehicleComponent.GetSeats(vehicle.GetGame(), vehicle, seats) {
		//LogChannel(n"DEBUG", "There weren't any seats?");
      return false;
    };
	
	
	//LogChannel(n"DEBUG", ToString(ArraySize(seats)));
	let ranOutOfSeats: Bool = false;
	  slotName = n"seat_front_right";
	
	if Equals(slotName, n"seat_front_right") && !DCOFoundSeat{
		if vehicle.DCOFrontRightTaken || !AISubActionMountVehicle_Record_Implementation.DCOCheckSlot(vehicle, n"seat_front_right") {
			
			slotName = n"seat_back_left";
			if ArraySize(seats)<3 { 
				ranOutOfSeats = true;
			};
			
		}
		else{
			//if VehicleComponent.IsSlotAvailable(ScriptExecutionContext.GetOwner(context).GetGame(), vehicle, slotName){
				vehicle.DCOFrontRightTaken = true;
				vehicle.DCOBackLeftTaken = false;
				DCOFoundSeat = true;
				//vehicle.DCOBackRightTaken = false;
			//}
			
			
		}
	}
	if Equals(slotName, n"seat_back_left") && !DCOFoundSeat{
		if vehicle.DCOBackLeftTaken  || !AISubActionMountVehicle_Record_Implementation.DCOCheckSlot(vehicle, n"seat_back_left") || ranOutOfSeats {
			slotName = n"seat_back_right";
			if ArraySize(seats)<4{
				ranOutOfSeats = true;
			};
		}
		else{
			//if VehicleComponent.IsSlotAvailable(ScriptExecutionContext.GetOwner(context).GetGame(), vehicle, slotName){
				vehicle.DCOBackLeftTaken = true;
				vehicle.DCOBackRightTaken = false;
				DCOFoundSeat = true;
				//vehicle.DCOFrontRightTaken = false;
			//}
		}
	}
	
	if Equals(slotName, n"seat_back_right") && !DCOFoundSeat{
	
		//Attempt to mount a different vehicle
		if vehicle.DCOBackRightTaken || !AISubActionMountVehicle_Record_Implementation.DCOCheckSlot(vehicle, n"seat_back_right") || ranOutOfSeats{
			//LogChannel(n"DEBUG", "DCO all were taken");
			/*
			let q: Int32 = 0;
			while q <ArraySize(GameInstance.GetCompanionSystem(gi).DCOPlayerVehicles) {
				if AISubActionMountVehicle_Record_Implementation.DCOMountOtherVehicle(context, GameInstance.GetCompanionSystem(gi).DCOPlayerVehicles[q]){
					//LogChannel(n"DEBUG", "Returned true here wtf.");
					return true;
				}
				q+=1;
			}
			//LogChannel(n"DEBUG", "Bad vehicle");
			*/
			
			//Put androids in the trunk
			//slotName = n"trunk_body";
			
			return false;
		}
		else {
			//if VehicleComponent.IsSlotAvailable(ScriptExecutionContext.GetOwner(context).GetGame(), vehicle, slotName){
				vehicle.DCOBackRightTaken = true;
				//vehicle.DCOBackLeftTaken = false;
				vehicle.DCOFrontRightTaken = false;
				DCOFoundSeat = true;
			//}
		}
	}
	
    mountData = new MountEventData();
    mountData.slotName = slotName;
	if Equals((ScriptExecutionContext.GetOwner(context) as NPCPuppet).GetNPCType(), gamedataNPCType.Drone){
		mountData.slotName = TweakDBInterface.GetCName(t"DCO.DroneCarSlot", n"trunk_body");
	};
    mountData.mountParentEntityId = vehicle.GetEntityID();
    mountData.isInstant = false; //record.MountInstantly();
    mountData.ignoreHLS = true;
    evt = new MountAIEvent();
    evt.name = n"Mount";
    evt.data = mountData;
    ScriptExecutionContext.GetOwner(context).QueueEvent(evt);
	////LogChannel(n"DEBUG", "Should've mounted");
    return true;
  }

@addMethod(AISubActionMountVehicle_Record_Implementation)
public static func DCOCheckSlot(vehicle: wref<VehicleObject>, slot: CName) -> Bool{
	let i: Int32 = 0;
	let gi: GameInstance = vehicle.GetGame();
	let mi: MountingInfo;
	let entities: array<wref<Entity>>;
	GameInstance.GetCompanionSystem(gi).GetSpawnedEntities(entities);
	while i<ArraySize(entities){
		mi = GameInstance.GetMountingFacility(vehicle.GetGame()).GetMountingInfoSingleWithObjects(entities[i] as GameObject);
		if Equals(mi.slotId.id, slot){
			return false;
		}
		i+=1;
	}
	return true;
}

@wrapMethod(VehicleComponent)
  private final func CreateMappin() -> Void {
    let isBike: Bool;
    let mappinData: MappinData;
    let system: ref<MappinSystem>;
    if this.CanShowMappin() {
      if Equals(this.m_mappinID.value, Cast(0u)) {
		if !this.GetVehicle().IsPrevention(){
			//LogChannel(n"DEBUG", "Pushed player vehicle to companion system");
			ArrayPush(GameInstance.GetCompanionSystem(this.GetVehicle().GetGame()).DCOPlayerVehicles, this.GetVehicle());
		}
      };
    };
	wrappedMethod();
  }
  
@addMethod(AISubActionMountVehicle_Record_Implementation)
 public final static func DCOMountOtherVehicle(context: ScriptExecutionContext, vehicle: wref<VehicleObject>) -> Bool {
	//LogChannel(n"DEBUG", "Starting other vehicle mount");
	if !IsDefined(vehicle){
		//LogChannel(n"DEBUG", "Vehicle wasn't defined RMOUNT");

		return false;
	}
	
	

    let evt: ref<MountAIEvent>;
    let mountData: ref<MountEventData>;
    let slotName: CName;
    let vehicle: wref<VehicleObject>;
	let gi: GameInstance = ScriptExecutionContext.GetOwner(context).GetGame();
	
	if GameInstance.GetBlackboardSystem(gi).GetLocalInstanced(GetPlayer(gi).GetEntityID(), GetAllBlackboardDefs().PlayerStateMachine).GetInt(GetAllBlackboardDefs().PlayerStateMachine.SceneTier) >1{
		return false;
	};
	
	//LogChannel(n"DEBUG", ToString(Vector4.Distance(vehicle.GetWorldPosition(), ScriptExecutionContext.GetOwner(context).GetWorldPosition())));
	/*
	if Vector4.Distance(vehicle.GetWorldPosition(), ScriptExecutionContext.GetOwner(context).GetWorldPosition()) > 30.0 {
		//LogChannel(n"DEBUG", "Vehicle too far away");
		return false;
	};*/
	


    if vehicle.IsDestroyed() {
		//LogChannel(n"DEBUG", "Vehicle destroyed what???");
      return false;
    };
	let DCOFoundSeat: Bool;
	////LogChannel(n"DEBUG", ToString(vehicle.DCOFrontRightTaken) + " " + ToString(vehicle.DCOBackLeftTaken) + " " + ToString(vehicle.DCOBackRightTaken));
	//LogChannel(n"DEBUG", "Iterating through DCO seats REMOUNT");
	//Check for if the seats been taken
	
	/*
    let seats: array<wref<VehicleSeat_Record>>;
    if !VehicleComponent.GetSeats(vehicle.GetGame(), vehicle, seats) {
		//LogChannel(n"DEBUG", "There weren't any seats? REMOUNT");
      return false;
    };
	*/
	
	////LogChannel(n"DEBUG", ToString(ArraySize(seats)));
	  slotName = n"seat_front_left";
	
	if Equals(slotName, n"seat_front_left") && !DCOFoundSeat{
		if vehicle.DCOFrontRightTaken || !AISubActionMountVehicle_Record_Implementation.DCOCheckSlot(vehicle, n"seat_front_left") {
			
			slotName = n"seat_back_right";
			/*if ArraySize(seats)<3 { 
				return false;
			};
			*/
		}
		else{
			//if VehicleComponent.IsSlotAvailable(ScriptExecutionContext.GetOwner(context).GetGame(), vehicle, slotName){
				vehicle.DCOFrontLeftTaken = true;
				vehicle.DCOFrontRightTaken = false;
				DCOFoundSeat = true;
				//vehicle.DCOBackRightTaken = false;
			//}
			
			
		}
	}
	
	if Equals(slotName, n"seat_front_right") && !DCOFoundSeat{
		if vehicle.DCOFrontRightTaken || !AISubActionMountVehicle_Record_Implementation.DCOCheckSlot(vehicle, n"seat_front_right") {
			
			slotName = n"seat_back_left";
			/*if ArraySize(seats)<3 { 
				return false;
			};
			*/
		}
		else{
			//if VehicleComponent.IsSlotAvailable(ScriptExecutionContext.GetOwner(context).GetGame(), vehicle, slotName){
				vehicle.DCOFrontRightTaken = true;
				vehicle.DCOBackLeftTaken = false;
				DCOFoundSeat = true;
				//vehicle.DCOBackRightTaken = false;
			//}
			
			
		}
	}
	if Equals(slotName, n"seat_back_left") && !DCOFoundSeat{
		if vehicle.DCOBackLeftTaken  || !AISubActionMountVehicle_Record_Implementation.DCOCheckSlot(vehicle, n"seat_back_left") {
			slotName = n"seat_back_right";
			/*if ArraySize(seats)<4{
				return false;
			};*/
		}
		else{
			//if VehicleComponent.IsSlotAvailable(ScriptExecutionContext.GetOwner(context).GetGame(), vehicle, slotName){
				vehicle.DCOBackLeftTaken = true;
				vehicle.DCOBackRightTaken = false;
				DCOFoundSeat = true;
				//vehicle.DCOFrontRightTaken = false;
			//}
		}
	}
	
	if Equals(slotName, n"seat_back_right") && !DCOFoundSeat{
	
		//Attempt to mount a different vehicle
		if vehicle.DCOBackRightTaken || !AISubActionMountVehicle_Record_Implementation.DCOCheckSlot(vehicle, n"seat_back_right"){
			//LogChannel(n"DEBUG", "DCO all were taken REMOUNT");
			
			return false;
		}
		else {
			//if VehicleComponent.IsSlotAvailable(ScriptExecutionContext.GetOwner(context).GetGame(), vehicle, slotName){
				vehicle.DCOBackRightTaken = true;
				//vehicle.DCOBackLeftTaken = false;
				vehicle.DCOFrontLeftTaken = false;
				DCOFoundSeat = true;
			//}
		}
	}
	
    mountData = new MountEventData();
    mountData.slotName = slotName;

    mountData.mountParentEntityId = vehicle.GetEntityID();
    mountData.isInstant = true; //record.MountInstantly();
    mountData.ignoreHLS = true;
    evt = new MountAIEvent();
    evt.name = n"Mount";
    evt.data = mountData;
    ScriptExecutionContext.GetOwner(context).QueueEvent(evt);
	
	if Equals(slotName, n"seat_front_left"){
		let cmd: ref<AIVehicleFollowCommand> = new AIVehicleFollowCommand();
		cmd.target = GetPlayer(gi);
		cmd.stopWhenTargetReached = false;
		cmd.distanceMin = 4;
		cmd.distanceMax = 8;
		cmd.useTraffic = false;
		cmd.needDriver = true;
		let evt: ref<AICommandEvent> = new AICommandEvent();
		evt.command = cmd;
		vehicle.QueueEvent(evt);
	}
	//LogChannel(n"DEBUG", ToString(slotName));
	//LogChannel(n"DEBUG", "Should've mounted");
    return true;
  }
