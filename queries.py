from connection import MySQLConnection
from PyQt6.QtWidgets import QApplication, QMainWindow, QWidget, QLabel, QLineEdit, QVBoxLayout, QHBoxLayout, QPushButton, QStackedWidget, QLineEdit, QComboBox, QStatusBar, QTableWidget, QTableWidgetItem

# 1
def design_add_airplane(self):
    vbox = QVBoxLayout()

    hbox1 = QHBoxLayout()
    self.airline = QLabel("airlineID")
    self.airline.setFixedWidth(50)
    combobox1 = QComboBox()
    with MySQLConnection() as conn:
        with conn.cursor() as cursor:
            cursor.execute("SELECT * FROM airline")
            result = cursor.fetchall()
    
    for tuple in result:
        combobox1.addItem(tuple['airlineID'])
    # combobox1.addItem('One')
    # combobox1.addItem('Two')
    # combobox1.addItem('Three')
    # combobox1.addItem('Four')
    self.combobox2 = QComboBox()
    self.combobox2.setFixedWidth(80)
    def update_tail_num():
        with MySQLConnection() as conn:
            with conn.cursor() as cursor:
                print("airlineID is " + str(combobox1.currentText()))
                cursor.execute("SELECT * FROM airplane WHERE airlineID = '" + str(combobox1.currentText()) + "'")
                result = cursor.fetchall()
                print("result = " + str(result))
        self.combobox2.clear()
        for tuple in result:
            self.combobox2.addItem(tuple['tail_num'])
    

    combobox1.currentIndexChanged.connect(update_tail_num)
    combobox1.setFixedWidth(80)
    hbox1.addWidget(self.airline)
    hbox1.addWidget(combobox1)
    self.route_id_button= QLabel("plane_type")
    self.route_id_button.setFixedWidth(70)
    self.plane_type = QLineEdit()
    self.plane_type.setFixedWidth(200)
    hbox1.addWidget(self.route_id_button)
    hbox1.addWidget(self.plane_type)

    hbox2 = QHBoxLayout()
    self.tailnum = QLabel("tailnum")
    self.tailnum.setFixedWidth(50)
    
    hbox2.addWidget(self.tailnum)
    hbox2.addWidget(self.combobox2)
    self.tailnum2= QLabel("skids")
    self.tailnum2.setFixedWidth(40)
    self.plane_type = QLineEdit()
    self.plane_type.setFixedWidth(200)
    hbox2.addWidget(self.tailnum2)
    hbox2.addWidget(self.plane_type)

    hbox3 = QHBoxLayout()
    self.seat_capacity = QLabel("seat_capacity")
    self.seat_capacity1 = QLineEdit()
    hbox3.addWidget(self.seat_capacity)
    hbox3.addWidget(self.seat_capacity1)

    self.propeller = QLabel("propeller")
    self.propeller1 = QLineEdit()
    hbox3.addWidget(self.propeller)
    hbox3.addWidget(self.propeller1)

    hbox4 = QHBoxLayout()
    self.speed = QLabel("speed")
    self.speed1 = QLineEdit()
    hbox4.addWidget(self.speed)
    hbox4.addWidget(self.speed1)
    self.jet_engine = QLabel("jet_engine")
    self.jet_engine1= QLineEdit()
    hbox4.addWidget(self.jet_engine)
    hbox4.addWidget(self.jet_engine1)

    hbox5 = QHBoxLayout()
    self.locationID = QLabel("location_id")
    combobox3 = QComboBox()
    with MySQLConnection() as conn:
        with conn.cursor() as cursor:
            cursor.execute("SELECT * FROM location")
            result = cursor.fetchall()
    
    combobox3.addItem('')
    for tuple in result:
        combobox3.addItem(tuple['locationID'])
    
    hbox5.addWidget(self.locationID)
    hbox5.addWidget(combobox3)


    hbox6 = QHBoxLayout()
    self.cancel = QPushButton("cancel")
    self.cancel.clicked.connect(lambda: self.pages.setCurrentIndex(0))
    self.add = QPushButton("add")
    def execute_add_airplane():
        with MySQLConnection() as conn:
            with conn.cursor() as cursor:
                # print("selected routeID: " + word_entry.text())
                sc = self.seat_capacity1.text()
                if sc == "":
                    sc = None
                
                s = self.speed1.text()
                if s == "":
                    s = None
                
                locID = combobox3.currentText()
                if locID == "":
                    locID = None
                
                pt = self.plane_type()
                if pt == "":
                    pt = None
                cursor.callproc('add_ariplane', args=(combobox1.currentText(), self.combobox2.currentText(), sc, s, locID, pt, ))
                conn.commit()
        self.seat_capacity1.setText("")
        self.plante_type.setText("")
    self.add.clicked.connect(execute_add_airplane)
    hbox6.addWidget(self.cancel)
    hbox6.addWidget(self.add)

    vbox.addLayout(hbox1)
    vbox.addLayout(hbox2)
    vbox.addLayout(hbox3)
    vbox.addLayout(hbox4)
    vbox.addLayout(hbox5)
    vbox.addLayout(hbox6)
    self.add_airplane_page.setLayout(vbox)
# 2
def design_add_airport(self):
    vbox = QVBoxLayout()

    hbox1 = QHBoxLayout()
    hbox1.addWidget(QLabel("airportID")) 
    self.seat12 = QLineEdit()
    hbox1.addWidget(self.seat12)

    hbox2 = QHBoxLayout()
    hbox2.addWidget(QLabel("airport_name")) 
    self.seat22 = QLineEdit()
    hbox2.addWidget(self.seat22)

    hbox3 = QHBoxLayout()
    hbox3.addWidget(QLabel("City")) 
    self.seat32 = QLineEdit()
    hbox3.addWidget(self.seat32)

    hbox4 = QHBoxLayout()
    hbox4.addWidget(QLabel("State")) 
    self.seat42 = QLineEdit()
    hbox4.addWidget(self.seat42)

        
    hbox5 = QHBoxLayout()
    hbox5.addWidget(QLabel("location_id"))
    combobox3 = QComboBox()
    with MySQLConnection() as conn:
        with conn.cursor() as cursor:
            cursor.execute("SELECT * FROM location")
            result = cursor.fetchall()
    combobox3.addItem("")
    for tuple in result:
        combobox3.addItem(tuple['locationID'])
    hbox5.addWidget(combobox3)

    hbox7 = QHBoxLayout()
    cancel10_button = QPushButton("Cancel")
    hbox7.addWidget(cancel10_button)
    cancel10_button.clicked.connect(lambda: self.pages.setCurrentIndex(0))
    
    update10_button = QPushButton("Add")
    hbox7.addWidget(update10_button)

    def call_add_airport():
        with MySQLConnection() as conn:
            with conn.cursor() as cursor:
                locID = combobox3.currentText()
                if locID == "":
                    locID = None
                cursor.callproc('add_airport', args=(self.seat12.text(), self.seat22.text(), self.seat32.text(), self.seat42.text(), locID))
                conn.commit()
        self.word_entry.setText("")
        self.statusBar = QStatusBar()
        self.setStatusBar(self.statusBar)
        self.statusBar.showMessage('Airport add was successful!', 5000)
    update10_button.clicked.connect(call_add_airport)


    vbox.addLayout(hbox1)
    vbox.addLayout(hbox2)
    vbox.addLayout(hbox3)
    vbox.addLayout(hbox4)
    vbox.addLayout(hbox5)
    vbox.addLayout(hbox7)
    self.add_airport_page.setLayout(vbox)


# 3
def design_add_person(self):
    pass

# 4
def design_grant_pilot_license(self):
    pass

# 5
def design_offer_flight(self):
    pass

# 6
def design_purchase_ticket_and_seat(self):
    import sys
    from PyQt6.QtWidgets import QApplication, QWidget, QPushButton, QHBoxLayout, QVBoxLayout, QComboBox, QLineEdit, QLabel

    vbox = QVBoxLayout()

    hbox1 = QHBoxLayout()
    hbox1.addWidget(QLabel("ticketID")) 
    self.seat1 = QLineEdit()
    hbox1.addWidget(self.seat1)

    hbox2 = QHBoxLayout()
    hbox2.addWidget(QLabel("Cost"))
    self.seat_capacity1 = QLineEdit()
    hbox2.addWidget(self.seat_capacity1)

    hbox3 = QHBoxLayout()
    hbox3.addWidget(QLabel("carrier"))
    self.seat_capacity2 = QLineEdit()
    hbox3.addWidget(self.seat_capacity2)

    hbox4 = QHBoxLayout()
    hbox4.addWidget(QLabel("customer"))
    self.seat_capacity3 = QLineEdit()
    hbox4.addWidget(self.seat_capacity3)

    hbox5 = QHBoxLayout()
    hbox5.addWidget(QLabel("airportID"))
    combobox3 = QComboBox()
    with MySQLConnection() as conn:
        with conn.cursor() as cursor:
            cursor.execute("SELECT * FROM airport")
            result = cursor.fetchall()
    
    for tuple in result:
        combobox3.addItem(tuple['airportID'])
    hbox5.addWidget(combobox3)

    hbox6 = QHBoxLayout()
    hbox6.addWidget(QLabel("deplane_at"))
    self.seat_capacity4 = QLineEdit()
    hbox6.addWidget(self.seat_capacity4)

    hbox7 = QHBoxLayout()
    cancel10_button = QPushButton("Cancel")
    hbox7.addWidget(cancel10_button)
    cancel10_button.clicked.connect(lambda: self.pages.setCurrentIndex(0))
    
    update10_button = QPushButton("Update")
    hbox7.addWidget(update10_button)

    def execute_purchase_ticket_and_seat():
        with MySQLConnection() as conn:
            with conn.cursor() as cursor:
                cursor.callproc('purchase_ticket_and_seat', args=(self.seat1.text(), self.seat_capacity1.text(), self.seat_capacity2.text(), self.seat_capacity3.text(), combobox3.currentText(), self.seat_capacity4.text()))
                conn.commit()
        self.seat_capacity1.setText("")
        self.statusBar = QStatusBar()
        self.setStatusBar(self.statusBar)
        self.statusBar.showMessage('Ticket purchased successfully!', 5000)
    update10_button.clicked.connect(execute_purchase_ticket_and_seat)


    vbox.addLayout(hbox1)
    vbox.addLayout(hbox2)
    vbox.addLayout(hbox3)
    vbox.addLayout(hbox4)
    vbox.addLayout(hbox5)
    vbox.addLayout(hbox6)
    vbox.addLayout(hbox7)
    self.purchase_ticket_and_seat_page.setLayout(vbox)

# 7
def design_add_update_leg(self):
    vbox = QVBoxLayout()

    hbox1 = QHBoxLayout()
    hbox1.addWidget(QLabel("legID")) 
    self.seat1 = QLineEdit()
    hbox1.addWidget(self.seat1)

    hbox2 = QHBoxLayout()
    hbox2.addWidget(QLabel("Distance")) 
    self.seat2 = QLineEdit()
    hbox2.addWidget(self.seat2)
        
    hbox5 = QHBoxLayout()
    hbox5.addWidget(QLabel("Departure"))
    combobox3 = QComboBox()
    with MySQLConnection() as conn:
        with conn.cursor() as cursor:
            cursor.execute("SELECT * FROM airport")
            result = cursor.fetchall()
    
    for tuple in result:
        combobox3.addItem(tuple['airportID'])
    hbox5.addWidget(combobox3)

    hbox6 = QHBoxLayout()
    hbox6.addWidget(QLabel("Arrival"))
    combobox4 = QComboBox()
    with MySQLConnection() as conn:
        with conn.cursor() as cursor:
            cursor.execute("SELECT * FROM airport")
            result = cursor.fetchall()
    
    for tuple in result:
        combobox4.addItem(tuple['airportID'])
    hbox6.addWidget(combobox4)

    hbox7 = QHBoxLayout()
    cancel10_button = QPushButton("Cancel")
    hbox7.addWidget(cancel10_button)
    cancel10_button.clicked.connect(lambda: self.pages.setCurrentIndex(0))
    
    update10_button = QPushButton("Assign")
    hbox7.addWidget(update10_button)

    def execute_add_update_leg():
        with MySQLConnection() as conn:
            with conn.cursor() as cursor:
                cursor.callproc('add_update_leg', args=(self.seat1.text(), self.seat2.text(), combobox3.currentText(), combobox4.currentText()))
                conn.commit()
        self.word_entry.setText("")
        self.statusBar = QStatusBar()
        self.setStatusBar(self.statusBar)
        self.statusBar.showMessage('Leg change/add was successful!', 5000)
    update10_button.clicked.connect(execute_add_update_leg)


    vbox.addLayout(hbox1)
    vbox.addLayout(hbox2)
    vbox.addLayout(hbox5)
    vbox.addLayout(hbox6)
    vbox.addLayout(hbox7)
    self.add_update_leg_page.setLayout(vbox)

# 8
def design_start_route(self):
    vbox = QVBoxLayout()
    hbox1 = QHBoxLayout()
    hbox1.addWidget(QLabel("routeID"))
    word_entry = QLineEdit()
    hbox1.addWidget(word_entry)
    hbox2 = QHBoxLayout()
    hbox2.addWidget(QLabel("legID"))
    combobox1 = QComboBox()
    with MySQLConnection() as conn:
        with conn.cursor() as cursor:
            cursor.execute("SELECT legID FROM leg")
            result = cursor.fetchall()
    
    for tuple in result:
        combobox1.addItem(tuple['legID'])
    hbox2.addWidget(combobox1)

    hbox3 = QHBoxLayout()
    cancel8_button = QPushButton("Cancel")
    hbox3.addWidget(cancel8_button)
    cancel8_button.clicked.connect(lambda: self.pages.setCurrentIndex(0))

    assign8_button = QPushButton("Assign")
    hbox3.addWidget(assign8_button)
    def call_start_route():
        with MySQLConnection() as conn:
            with conn.cursor() as cursor:
                # print("selected routeID: " + word_entry.text())
                cursor.callproc('start_route', args=(word_entry.text(), combobox1.currentText()))
                conn.commit()
        word_entry.setText("")
        self.statusBar = QStatusBar()
        self.setStatusBar(self.statusBar)
        self.statusBar.showMessage('Route started successfully!', 5000)
    assign8_button.clicked.connect(call_start_route)

    vbox.addLayout(hbox1)
    vbox.addLayout(hbox2)
    vbox.addLayout(hbox3)

    self.start_route_page.setLayout(vbox)

# 9
def design_extend_route(self):
    vbox = QVBoxLayout()

    hbox1 = QHBoxLayout()
    hbox1.addWidget(QLabel("routeID"))
    self.word_entry = QLineEdit()
    hbox1.addWidget(self.word_entry)

    hbox2 = QHBoxLayout()
    hbox2.addWidget(QLabel("legID"))

    combobox1 = QComboBox()
    with MySQLConnection() as conn:
        with conn.cursor() as cursor:
            cursor.execute("SELECT legID FROM leg")
            result = cursor.fetchall()
    for tuple in result:
        combobox1.addItem(tuple['legID'])
    hbox2.addWidget(combobox1)

    hbox3 = QHBoxLayout()

    cancel9_button = QPushButton("Cancel")
    hbox3.addWidget(cancel9_button)
    cancel9_button.clicked.connect(lambda: self.pages.setCurrentIndex(0))

    assign9_button = QPushButton("Assign")
    hbox3.addWidget(assign9_button)
    def call_extend_route():
        with MySQLConnection() as conn:
            with conn.cursor() as cursor:
                cursor.callproc('extend_route', args=(self.word_entry.text(), combobox1.currentText()))
                conn.commit()
        self.word_entry.setText("")
        self.statusBar = QStatusBar()
        self.setStatusBar(self.statusBar)
        self.statusBar.showMessage('Route extended successfully!', 5000)
    assign9_button.clicked.connect(call_extend_route)

    vbox.addLayout(hbox1)
    vbox.addLayout(hbox2)
    vbox.addLayout(hbox3)

    self.extend_route_page.setLayout(vbox)

# 10
def design_flight_landing(self):
    vbox = QVBoxLayout()

    hbox1 = QHBoxLayout()
    hbox1.addWidget(QPushButton("flightID"))
    self.word_entry = QLineEdit()
    hbox1.addWidget(self.word_entry)

    hbox2 = QHBoxLayout()
    cancel10_button = QPushButton("Cancel")
    hbox2.addWidget(cancel10_button)
    cancel10_button.clicked.connect(lambda: self.pages.setCurrentIndex(0))
    
    update10_button = QPushButton("Update")
    hbox2.addWidget(update10_button)
    def call_flight_landing():
        with MySQLConnection() as conn:
            with conn.cursor() as cursor:
                cursor.callproc('flight_landing', args=(self.word_entry.text(),))
                conn.commit()
        self.word_entry.setText("")
        self.statusBar = QStatusBar()
        self.setStatusBar(self.statusBar)
        self.statusBar.showMessage('Flight landed successfully!', 5000)
    update10_button.clicked.connect(call_flight_landing)

    vbox.addLayout(hbox1)
    vbox.addLayout(hbox2)

    self.flight_landing_page.setLayout(vbox)

# 11
def design_flight_takeoff(self):
    pass

# 12
def design_passengers_board(self):
    pass

# 13
def design_passengers_disembark(self):
    pass

# 14
def design_assign_pilot(self):
    vbox = QVBoxLayout()

    hbox1 = QHBoxLayout()
    
    hbox1.addWidget(QLabel('personID'))
   
    hbox2 = QHBoxLayout()
    hbox2.addWidget(QLabel("Flight"))

    combobox1 = QComboBox()

    with MySQLConnection() as conn:
        with conn.cursor() as cursor:
            cursor.execute("SELECT personID FROM person")
            result = cursor.fetchall()
    for tuple in result:
        combobox1.addItem(tuple['personID'])

    hbox1.addWidget(combobox1)

    combobox2 = QComboBox()

    with MySQLConnection() as conn:
        with conn.cursor() as cursor:
            cursor.execute("SELECT flightID FROM flight")
            result1 = cursor.fetchall()
    for tuple in result1:
        combobox2.addItem(tuple['flightID'])

    hbox2.addWidget(combobox2)

    hbox3 = QHBoxLayout()

    cancel14_button = QPushButton('Cancel')
    hbox3.addWidget(cancel14_button)
    cancel14_button.clicked.connect(lambda: self.pages.setCurrentIndex(0))

    assign14_button = QPushButton('Assign')
    hbox3.addWidget(assign14_button)
    def call_assign_pilot():
        with MySQLConnection() as conn:
            with conn.cursor() as cursor:
                cursor.callproc('assign_pilot', args=(combobox2.currentText(), combobox1.currentText()))
                conn.commit()

        self.statusBar = QStatusBar()
        self.setStatusBar(self.statusBar)
        self.statusBar.showMessage('Pilot assigned successfully!', 5000)
    assign14_button.clicked.connect(call_assign_pilot)

    vbox.addLayout(hbox1)
    vbox.addLayout(hbox2)
    vbox.addLayout(hbox3)
        
    self.assign_pilot_page.setLayout(vbox)

# 15
def design_recycle_crew(self):

    vbox = QVBoxLayout()

    hbox1 = QHBoxLayout()
    
    hbox1.addWidget(QLabel('Flight'))

    combobox1 = QComboBox()

    with MySQLConnection() as conn:
        with conn.cursor() as cursor:
            cursor.execute("SELECT flightID FROM flight")
            result = cursor.fetchall()
    for tuple in result:
        combobox1.addItem(tuple['flightID'])

    hbox1.addWidget(combobox1)

    hbox3 = QHBoxLayout()

    cancel14_button = QPushButton('Cancel')
    hbox3.addWidget(cancel14_button)
    cancel14_button.clicked.connect(lambda: self.pages.setCurrentIndex(0))

    assign14_button = QPushButton('Recycle Crew')
    hbox3.addWidget(assign14_button)
    def call_recycle_crew():
        with MySQLConnection() as conn:
            
            with conn.cursor() as cursor:
                
                
                setup1 = "update flight set progress = 3 where flightID = 'AM_1523';"
                setup2 = "update person set locationID = 'port_5' where personID in ('p26', 'p40', 'p41');"
                cursor.execute(setup1)
                cursor.execute(setup2)
                #result = cursor.fetchall()
                cursor.callproc('recycle_crew', args=(combobox1.currentText(),))
                conn.commit()

        self.statusBar = QStatusBar()
        self.setStatusBar(self.statusBar)
        self.statusBar.showMessage('Crew Recycled!', 5000)
    assign14_button.clicked.connect(call_recycle_crew)

    vbox.addLayout(hbox1)
    vbox.addLayout(hbox3)
        
    self.recycle_crew_page.setLayout(vbox)
# 16
def design_retire_flight(self):
    vbox = QVBoxLayout()

    hbox1 = QHBoxLayout()
    
    hbox1.addWidget(QLabel("flightID"))
    self.word_entry = QLineEdit()
    hbox1.addWidget(self.word_entry)

    hbox3 = QHBoxLayout()

    cancel14_button = QPushButton('Cancel')
    hbox3.addWidget(cancel14_button)
    cancel14_button.clicked.connect(lambda: self.pages.setCurrentIndex(0))

    assign14_button = QPushButton('Update')
    hbox3.addWidget(assign14_button)
    def call_retire_flight():
        with MySQLConnection() as conn:
            with conn.cursor() as cursor:
                cursor.callproc('retire_flight', args=(self.word_entry.text(),))
                conn.commit()
        self.word_entry.setText("")
        self.statusBar = QStatusBar()
        self.setStatusBar(self.statusBar)
        self.statusBar.showMessage('Flight Retired!', 5000)
    assign14_button.clicked.connect(call_retire_flight)

    vbox.addLayout(hbox1)
    vbox.addLayout(hbox3)
        
    self.retire_flight_page.setLayout(vbox)

# 17
def design_remove_passenger_role(self):
    vbox = QVBoxLayout()

    hbox1 = QHBoxLayout()
    
    hbox1.addWidget(QLabel("personID"))

    combobox1 = QComboBox()
    with MySQLConnection() as conn:
        with conn.cursor() as cursor:
            cursor.execute("SELECT personID FROM passenger")
            result = cursor.fetchall()
    for tuple in result:
        combobox1.addItem(tuple['personID'])
    hbox1.addWidget(combobox1)

    hbox3 = QHBoxLayout()

    cancel14_button = QPushButton('Cancel')
    hbox3.addWidget(cancel14_button)
    cancel14_button.clicked.connect(lambda: self.pages.setCurrentIndex(0))

    assign14_button = QPushButton('Remove')
    hbox3.addWidget(assign14_button)
    def call_remove_passenger_role():
        with MySQLConnection() as conn:
            with conn.cursor() as cursor:
                cursor.callproc('remove_passenger_role', args=(combobox1.currentText(),))
                conn.commit()

        self.statusBar = QStatusBar()
        self.setStatusBar(self.statusBar)
        self.statusBar.showMessage('Passenger Removed!', 5000)
    assign14_button.clicked.connect(call_remove_passenger_role)

    vbox.addLayout(hbox1)
    vbox.addLayout(hbox3)
        
    self.remove_passenger_role_page.setLayout(vbox)

# 18
def design_remove_pilot_role(self):
    vbox = QVBoxLayout()

    hbox1 = QHBoxLayout()
    
    hbox1.addWidget(QLabel("personID"))

    combobox1 = QComboBox()
    with MySQLConnection() as conn:
        with conn.cursor() as cursor:
            cursor.execute("SELECT personID FROM pilot")
            result = cursor.fetchall()
    for tuple in result:
        combobox1.addItem(tuple['personID'])
    hbox1.addWidget(combobox1)

    hbox3 = QHBoxLayout()

    cancel14_button = QPushButton('Cancel')
    hbox3.addWidget(cancel14_button)
    cancel14_button.clicked.connect(lambda: self.pages.setCurrentIndex(0))

    assign14_button = QPushButton('Remove Pilot')
    hbox3.addWidget(assign14_button)
    def call_remove_pilot_role():
        with MySQLConnection() as conn:
            with conn.cursor() as cursor:
                cursor.callproc('remove_pilot_role', args=(combobox1.currentText(),))
                conn.commit()

        self.statusBar = QStatusBar()
        self.setStatusBar(self.statusBar)
        self.statusBar.showMessage('Pilot Removed!', 5000)
    assign14_button.clicked.connect(call_remove_pilot_role)

    vbox.addLayout(hbox1)
    vbox.addLayout(hbox3)
        
    self.remove_pilot_role_page.setLayout(vbox)

# 19
def design_flights_in_the_air(self):
    departure_pushbutton = QPushButton("Sort Departure Airport in Ascending Order")
    arrival_pushbutton = QPushButton("Sort Arrival Airport in Ascending Order")
    earliest_arrival_pushbutton = QPushButton("Sort Earliest Arrival in Ascending Order")
    latest_arrival_pushbutton = QPushButton("Sort Latest Arrival in Ascending Order")
    go_back_pushbutton = QPushButton("Go Back to the Main Screen")

    self.vbox = QVBoxLayout()
    self.vbox.addWidget(departure_pushbutton)
    self.vbox.addWidget(arrival_pushbutton)
    self.vbox.addWidget(earliest_arrival_pushbutton)
    self.vbox.addWidget(latest_arrival_pushbutton)

    def CreateTable(self, result):
        newTable = QTableWidget()
        rowCount = len(result)
        newTable.setRowCount(rowCount)
        newTable.setColumnCount(7)
        newTable.setHorizontalHeaderLabels(["Departure Airport", "Arrival Airport", "Number Flights", "Flight List", "Earliest Arrival", "Latest Arrival", "Airplane List"])
        newTable.setColumnWidth(0, 150)

        for i, data in enumerate(result):
            newTable.setItem(i, 0, QTableWidgetItem(data['departing_from']))
            newTable.setItem(i, 1, QTableWidgetItem(data['arriving_at']))
            newTable.setItem(i, 2, QTableWidgetItem(str(data['num_flights'])))
            newTable.setItem(i, 3, QTableWidgetItem(data['flight_list']))
            newTable.setItem(i, 4, QTableWidgetItem(str(data['earliest_arrival'])))
            newTable.setItem(i, 5, QTableWidgetItem(str(data['latest_arrival'])))
            newTable.setItem(i, 6, QTableWidgetItem(data['airplane_list']))
        
        self.vbox.replaceWidget(self.table, newTable)
        self.table = newTable
    
    with MySQLConnection() as conn:
            with conn.cursor() as cursor:
                cursor.execute("SELECT * FROM flights_in_the_air")
                result = cursor.fetchall()
    
    self.table = QTableWidget()
    self.vbox.addWidget(self.table)
    CreateTable(self, result)

    self.vbox.addWidget(go_back_pushbutton)
    
    def change_depart_text():
        if departure_pushbutton.text() == "Sort Departure Airport in Ascending Order":
            departure_pushbutton.setText("Sort Departure Airport in Descending Order")
            with MySQLConnection() as conn:
                with conn.cursor() as cursor:
                    cursor.execute("SELECT * FROM flights_in_the_air ORDER BY departing_from ASC")
                    result = cursor.fetchall()
            CreateTable(self, result)
        else:
            departure_pushbutton.setText("Sort Departure Airport in Ascending Order")
            with MySQLConnection() as conn:
                with conn.cursor() as cursor:
                    cursor.execute("SELECT * FROM flights_in_the_air ORDER BY departing_from DESC")
                    result = cursor.fetchall()
            CreateTable(self, result)

    def change_arrival_text():
        if arrival_pushbutton.text() == "Sort Arrival Airport in Ascending Order":
            arrival_pushbutton.setText("Sort Arrival Airport in Descending Order")
            with MySQLConnection() as conn:
                with conn.cursor() as cursor:
                    cursor.execute("SELECT * FROM flights_in_the_air ORDER BY arriving_at ASC")
                    result = cursor.fetchall()
            CreateTable(self, result)
        else:
            arrival_pushbutton.setText("Sort Arrival Airport in Ascending Order")
            with MySQLConnection() as conn:
                with conn.cursor() as cursor:
                    cursor.execute("SELECT * FROM flights_in_the_air ORDER BY arriving_at DESC")
                    result = cursor.fetchall()
            CreateTable(self, result)

    def change_earliest_text():
        if earliest_arrival_pushbutton.text() == "Sort Earliest Arrival in Ascending Order":
            earliest_arrival_pushbutton.setText("Sort Earliest Arrival in Descending Order")
            with MySQLConnection() as conn:
                with conn.cursor() as cursor:
                    cursor.execute("SELECT * FROM flights_in_the_air ORDER BY earliest_arrival ASC")
                    result = cursor.fetchall()
            CreateTable(self, result)
        else:
            earliest_arrival_pushbutton.setText("Sort Earliest Arrival in Ascending Order")
            with MySQLConnection() as conn:
                with conn.cursor() as cursor:
                    cursor.execute("SELECT * FROM flights_in_the_air ORDER BY earliest_arrival DESC")
                    result = cursor.fetchall()
            CreateTable(self, result)
    
    def change_latest_text():
        if latest_arrival_pushbutton.text() == "Sort Latest Arrival in Ascending Order":
            latest_arrival_pushbutton.setText("Sort Latest Arrival in Descending Order")
            with MySQLConnection() as conn:
                with conn.cursor() as cursor:
                    cursor.execute("SELECT * FROM flights_in_the_air ORDER BY latest_arrival ASC")
                    result = cursor.fetchall()
            CreateTable(self, result)
        else:
            latest_arrival_pushbutton.setText("Sort Latest Arrival in Ascending Order")
            with MySQLConnection() as conn:
                with conn.cursor() as cursor:
                    cursor.execute("SELECT * FROM flights_in_the_air ORDER BY latest_arrival DESC")
                    result = cursor.fetchall()
            CreateTable(self, result)

    departure_pushbutton.clicked.connect(change_depart_text)
    arrival_pushbutton.clicked.connect(change_arrival_text)
    earliest_arrival_pushbutton.clicked.connect(change_earliest_text)
    latest_arrival_pushbutton.clicked.connect(change_latest_text)
    go_back_pushbutton.clicked.connect(lambda: self.pages.setCurrentIndex(0))

    self.flights_in_the_air_page.setLayout(self.vbox)

# 20
def design_flights_on_the_ground(self):
    pass

# 21
def design_people_in_the_air(self):
    pass

# 22
def design_people_on_the_ground(self):
    pass

# 23
def design_route_summary(self):
    pass
# 24
def design_alternative_airports(self):
    pass

# 25
def design_simulation_cycle(self):
    pass