extends Node2D

export (PackedScene) var NumberItem

enum MoveStatus {
	NotMoving = 0,
	MovingLeft = 1,
	MovingRight = 2,
	MovingUp = 3,
	MovingDown = 4
}

var checkboardList = [
	null, null, null, null,
	null, null, null, null,
	null, null, null, null,
	null, null, null, null
]

var isMoving = false

var score = 0

func get_row_list_indices(direction: int):
	match direction:
		MoveStatus.MovingLeft: return [
			[0, 1, 2, 3],
			[4, 5, 6, 7],
			[8, 9, 10, 11],
			[12, 13, 14, 15]
		]
		MoveStatus.MovingRight: return [
			[3, 2, 1, 0],
			[7, 6, 5, 4],
			[11, 10, 9, 8],
			[15, 14, 13, 12]
		]
		MoveStatus.MovingUp: return [
			[0, 4, 8, 12],
			[1, 5, 9, 13],
			[2, 6, 10, 14],
			[3, 7, 11, 15]
		]
		MoveStatus.MovingDown: return [
			[12, 8, 4, 0],
			[13, 9, 5, 1],
			[14, 10, 6, 2],
			[15, 11, 7, 3]
		]
	

func new_number_item(xIndex: int, yIndex: int, level: int):
	# xIndex: 0 ~ 3; yIndex: 0 ~ 3
	var numberItem = NumberItem.instance()
	numberItem.xIndex = xIndex
	numberItem.yIndex = yIndex
	numberItem.level = level
	add_child(numberItem)
	self.checkboardList[xIndex + 4 * yIndex] = numberItem

func new_number_item_random():
	var emptyIndices = []
	for i in range(16):
		if(self.checkboardList[i] == null):
			emptyIndices.push_front(i)
	if(len(emptyIndices) == 0):
		return
	emptyIndices.shuffle()
	var xIndex = emptyIndices[0] % 4
	var yIndex = (emptyIndices[0] - xIndex) / 4
	new_number_item(xIndex, yIndex, 1)

func delete_number_item(index: int):
	remove_child(self.checkboardList[index])
	self.checkboardList[index].queue_free()
	self.checkboardList[index] = null

func restart():
	for i in self.checkboardList:
		if(i != null):
			remove_child(i)
	self.checkboardList = [
		null, null, null, null,
		null, null, null, null,
		null, null, null, null,
		null, null, null, null
	]
	new_number_item(0, 0, 1)
	self.score = 0
	$Score.text = "Score: 0"

func _on_MoveTimer_timeout():
	self.isMoving = false
	self.score = self.score + 1
	$Score.text = "Score: " + String(score)
	new_number_item_random()

# Called when the node enters the scene tree for the first time.
func _ready():
	new_number_item(0, 0, 1)

func move(direction: int):
	var rowListIndices = get_row_list_indices(direction)
	var tempItem
	var space: int
	var moved = false
	for rowIndices in rowListIndices:
		tempItem = null
		space = 0
		for i in range(4):
			var index = rowIndices[i]
			if(self.checkboardList[index] == null):
				space = space + 1
			else:
				if(tempItem == null or self.checkboardList[index].level != tempItem.level):
					tempItem = self.checkboardList[index]
					if space > 0:
						self.checkboardList[index].move(direction, space)
						self.checkboardList[rowIndices[i - space]] = self.checkboardList[index]
						self.checkboardList[index] = null
						moved = true
				else:
					self.delete_number_item(index)
					tempItem.double()
					# 在一次移动中，经过合并后生成的块，不能再进行合并，故将tempItem设为null
					tempItem = null
					space = space + 1
					moved = true
	if(moved):
		self.isMoving = true
		$MoveTimer.start(0.5)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if(isMoving):
		return
	if Input.is_action_pressed("ui_right"):
		self.move(MoveStatus.MovingRight)
	if Input.is_action_pressed("ui_left"):
		self.move(MoveStatus.MovingLeft)
	if Input.is_action_pressed("ui_down"):
		self.move(MoveStatus.MovingDown)
	if Input.is_action_pressed("ui_up"):
		self.move(MoveStatus.MovingUp)
