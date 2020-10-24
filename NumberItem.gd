extends Node2D

enum MoveStatus {
	NotMoving = 0,
	MovingLeft = 1,
	MovingRight = 2,
	MovingUp = 3,
	MovingDown = 4
}

# hsl(50, 50%, 80%)
const colors = ['#dde6b3', '#e6ddb3', '#e6ccb3', '#e6bbb3', '#e6b3bb', '#e6b3cc', '#e6b3dd', '#ddb3e6', '#ccb3e6', '#bbb3e6', '#b3bbe6', '#b3cce6', '#b3dde6']
const speed = 20

export var xIndex: int = 0
export var yIndex: int = 0
export var level: int = 1 # 数字是2的多少次方

var moveStatus = MoveStatus.NotMoving
var moveCount = 0
var doublingStatus = 0 # 0 > 1 >...> 7 > 0

func sync_position():
	self.position.x = (xIndex + 1) * 120
	self.position.y = (yIndex + 1) * 120

func sync_number():
	self.get_child(0).color = colors[(level - 1) % 13]
	self.get_child(1).text = String(pow(2, level))
	
func set_doublin_status(status: int):
	doublingStatus = status
	var newScale = 1.2 - abs(4 - doublingStatus) * 0.05
	$ColorRect.rect_scale.x = newScale
	$ColorRect.rect_scale.y = newScale
	
	
func move(moveStatus: int, moveCount: int):
	self.moveStatus = moveStatus
	self.moveCount = moveCount

func double():
	self.level = self.level + 1
	self.sync_number()
	doublingStatus = 1

# Called when the node enters the scene tree for the first time.
func _ready():
	sync_position()
	sync_number()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	# move
	if(self.moveStatus == MoveStatus.MovingLeft):
		if(self.position.x <= (self.xIndex - self.moveCount + 1) * 120):
			self.moveStatus = MoveStatus.NotMoving
			self.xIndex = self.xIndex - self.moveCount
		else:
			self.position.x = self.position.x - speed
	if(self.moveStatus == MoveStatus.MovingRight):
		if(self.position.x >= (self.xIndex + self.moveCount + 1) * 120):
			self.moveStatus = MoveStatus.NotMoving
			self.xIndex = self.xIndex + self.moveCount
		else:
			self.position.x = self.position.x + speed
	if(self.moveStatus == MoveStatus.MovingUp):
		if(self.position.y <= (self.yIndex - self.moveCount + 1) * 120):
			self.moveStatus = MoveStatus.NotMoving
			self.yIndex = self.yIndex - self.moveCount
		else:
			self.position.y = self.position.y - speed
	if(self.moveStatus == MoveStatus.MovingDown):
		if(self.position.y >= (self.yIndex + self.moveCount + 1) * 120):
			self.moveStatus = MoveStatus.NotMoving
			self.yIndex = self.yIndex + self.moveCount
		else:
			self.position.y = self.position.y + speed
	#double
	if(doublingStatus > 0 and doublingStatus < 8):
		set_doublin_status(doublingStatus + 1)
	else:
		set_doublin_status(0)
