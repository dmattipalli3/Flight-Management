import sys
import queries
from PyQt6.QtCore import QSize
from PyQt6.QtWidgets import QApplication, QMainWindow, QWidget, QLabel, QLineEdit, QVBoxLayout, QHBoxLayout, QPushButton, QStackedWidget, QLineEdit, QComboBox

class MainWindow(QMainWindow):
    def __init__(self):
        super().__init__()

        self.setWindowTitle("My App")
        self.setFixedSize(QSize(1200, 675))

        self.pages = QStackedWidget()
        self.setCentralWidget(self.pages)

        self.initialize_pages()

        # Design main_page
        self.design_main()

        # Design queries
        self.design_queries()

        # Add pages to the stack
        self.add_pages_to_stack()
            
    def initialize_pages(self):

        self.main_page = QWidget() #0: main page
        self.add_airplane_page = QWidget() # 1
        self.add_airport_page = QWidget() # 2
        self.add_person_page = QWidget() # 3
        self.grant_pilot_license_page = QWidget() # 4
        self.offer_flight_page = QWidget() # 5
        self.purchase_ticket_and_seat_page = QWidget() # 6
        self.add_update_leg_page = QWidget() # 7
        self.start_route_page = QWidget() # 8
        self.extend_route_page = QWidget() # 9
        self.flight_landing_page = QWidget() # 10
        self.flight_takeoff_page = QWidget() # 11
        self.passengers_board_page = QWidget() # 12
        self.passengers_disembark_page = QWidget() # 13
        self.assign_pilot_page = QWidget() # 14
        self.recycle_crew_page = QWidget() # 15
        self.retire_flight_page = QWidget() # 16
        self.remove_passenger_role_page = QWidget() # 17
        self.remove_pilot_role_page = QWidget() # 18
        self.flights_in_the_air_page = QWidget() # 19
        self.flights_on_the_ground_page = QWidget() # 20
        self.people_in_the_air_page = QWidget() # 21
        self.people_on_the_ground_page = QWidget() # 22
        self.route_summary_page = QWidget() # 23
        self.alternative_airports_page = QWidget() # 24
        self.simulation_cycle_page = QWidget() #25

    def design_main(self):
        self.create_main_page_buttons()

        outer_layout = QHBoxLayout() # outer layer
        left_layout = QVBoxLayout() # left pane
        right_layout = QVBoxLayout() # right pane

        left_layout.addWidget(self.add_airplane_button)
        left_layout.addWidget(self.add_airport_button)
        left_layout.addWidget(self.add_person_button)
        left_layout.addWidget(self.grant_pilot_license_button)
        left_layout.addWidget(self.offer_flight_button)
        left_layout.addWidget(self.purchase_ticket_and_seat_button)
        left_layout.addWidget(self.add_update_leg_button)
        left_layout.addWidget(self.start_route_button)
        left_layout.addWidget(self.extend_route_button)
        left_layout.addWidget(self.flight_landing_button)
        left_layout.addWidget(self.flight_takeoff_button)
        left_layout.addWidget(self.passengers_board_button)
        left_layout.addWidget(self.passengers_disembark_button) # 13

        outer_layout.addLayout(left_layout)

        self.main_label = QLabel("Simple Airline Management System (SAMS)")
        outer_layout.addWidget(self.main_label)

        right_layout.addWidget(self.assign_pilot_button)
        right_layout.addWidget(self.recycle_crew_button)
        right_layout.addWidget(self.retire_flight_button)
        right_layout.addWidget(self.remove_passenger_role_button)
        right_layout.addWidget(self.remove_pilot_role_button)
        right_layout.addWidget(self.flights_in_the_air_button)
        right_layout.addWidget(self.flights_on_the_ground_button)
        right_layout.addWidget(self.people_in_the_air_button)
        right_layout.addWidget(self.people_on_the_ground_button)
        right_layout.addWidget(self.route_summary_button)
        right_layout.addWidget(self.alternative_airports_button)
        right_layout.addWidget(self.simulation_cycle_button)

        outer_layout.addLayout(right_layout)

        self.main_page.setLayout(outer_layout)
        
    # Helper for design_main()
    def create_main_page_buttons(self):
        self.add_airplane_button = QPushButton("add_airplane()")
        self.add_airplane_button.clicked.connect(lambda: self.pages.setCurrentIndex(1))
        self.add_airport_button = QPushButton("add_airport()")
        self.add_airport_button.clicked.connect(lambda: self.pages.setCurrentIndex(2))
        self.add_person_button = QPushButton("add_person()")
        self.add_person_button.clicked.connect(lambda: self.pages.setCurrentIndex(3))
        self.grant_pilot_license_button = QPushButton("grant_pilot_license()")
        self.grant_pilot_license_button.clicked.connect(lambda: self.pages.setCurrentIndex(4))
        self.offer_flight_button = QPushButton("offer_flight()")
        self.offer_flight_button.clicked.connect(lambda: self.pages.setCurrentIndex(5))
        self.purchase_ticket_and_seat_button = QPushButton("purchase_ticket_and_seat()")
        self.purchase_ticket_and_seat_button.clicked.connect(lambda: self.pages.setCurrentIndex(6))
        self.add_update_leg_button = QPushButton("add_update_leg()")
        self.add_update_leg_button.clicked.connect(lambda: self.pages.setCurrentIndex(7))
        self.start_route_button = QPushButton("start_route()")
        self.start_route_button.clicked.connect(lambda: self.pages.setCurrentIndex(8))
        self.extend_route_button = QPushButton("extend_route()")
        self.extend_route_button.clicked.connect(lambda: self.pages.setCurrentIndex(9))
        self.flight_landing_button = QPushButton("flight_landing()")
        self.flight_landing_button.clicked.connect(lambda: self.pages.setCurrentIndex(10))
        self.flight_takeoff_button = QPushButton("flight_takeoff()")
        self.flight_takeoff_button.clicked.connect(lambda: self.pages.setCurrentIndex(11))
        self.passengers_board_button = QPushButton("passengers_board()")
        self.passengers_board_button.clicked.connect(lambda: self.pages.setCurrentIndex(12))
        self.passengers_disembark_button = QPushButton("passengers_disembark()")
        self.passengers_disembark_button.clicked.connect(lambda: self.pages.setCurrentIndex(13))
        self.assign_pilot_button = QPushButton("assign_pilot()")
        self.assign_pilot_button.clicked.connect(lambda: self.pages.setCurrentIndex(14))
        self.recycle_crew_button = QPushButton("recycle_crew()")
        self.recycle_crew_button.clicked.connect(lambda: self.pages.setCurrentIndex(15))
        self.retire_flight_button = QPushButton("retire_flight()")
        self.retire_flight_button.clicked.connect(lambda: self.pages.setCurrentIndex(16))
        self.remove_passenger_role_button = QPushButton("remove_passenger_role()")
        self.remove_passenger_role_button.clicked.connect(lambda: self.pages.setCurrentIndex(17))
        self.remove_pilot_role_button = QPushButton("remove_pilot_role()")
        self.remove_pilot_role_button.clicked.connect(lambda: self.pages.setCurrentIndex(18))
        self.flights_in_the_air_button = QPushButton("flights_in_the_air()")
        self.flights_in_the_air_button.clicked.connect(lambda: self.pages.setCurrentIndex(19))
        self.flights_on_the_ground_button = QPushButton("flights_on_the_ground()")
        self.flights_on_the_ground_button.clicked.connect(lambda: self.pages.setCurrentIndex(20))
        self.people_in_the_air_button = QPushButton("people_in_the_air()")
        self.people_in_the_air_button.clicked.connect(lambda: self.pages.setCurrentIndex(21))
        self.people_on_the_ground_button = QPushButton("people_on_the_ground()")
        self.people_on_the_ground_button.clicked.connect(lambda: self.pages.setCurrentIndex(22))
        self.route_summary_button = QPushButton("route_summary()")
        self.route_summary_button.clicked.connect(lambda: self.pages.setCurrentIndex(23))
        self.alternative_airports_button = QPushButton("alternative_airports()")
        self.alternative_airports_button.clicked.connect(lambda: self.pages.setCurrentIndex(24))
        self.simulation_cycle_button = QPushButton("simulation_cycle()")
        self.simulation_cycle_button.clicked.connect(lambda: self.pages.setCurrentIndex(25))
    
    def design_queries(self):
        queries.design_add_airplane(self)
        queries.design_add_airport(self)
        queries.design_add_person(self)
        queries.design_grant_pilot_license(self)
        queries.design_offer_flight(self)
        queries.design_purchase_ticket_and_seat(self)
        queries.design_add_update_leg(self)
        queries.design_start_route(self)
        queries.design_extend_route(self)
        queries.design_flight_landing(self)
        queries.design_flight_takeoff(self)
        queries.design_passengers_board(self)
        queries.design_passengers_disembark(self)
        queries.design_assign_pilot(self)
        queries.design_recycle_crew(self)
        queries.design_retire_flight(self)
        queries.design_remove_passenger_role(self)
        queries.design_remove_pilot_role(self)
        queries.design_flights_in_the_air(self)
        queries.design_flights_on_the_ground(self)
        queries.design_people_in_the_air(self)
        queries.design_people_on_the_ground(self)
        queries.design_route_summary(self)
        queries.design_alternative_airports(self)
        queries.design_simulation_cycle(self)
    
    def add_pages_to_stack(self):
        self.pages.addWidget(self.main_page)
        self.pages.addWidget(self.add_airplane_page)
        self.pages.addWidget(self.add_airport_page)
        self.pages.addWidget(self.add_person_page)
        self.pages.addWidget(self.grant_pilot_license_page)
        self.pages.addWidget(self.offer_flight_page)
        self.pages.addWidget(self.purchase_ticket_and_seat_page)
        self.pages.addWidget(self.add_update_leg_page)
        self.pages.addWidget(self.start_route_page)
        self.pages.addWidget(self.extend_route_page)
        self.pages.addWidget(self.flight_landing_page)
        self.pages.addWidget(self.flight_takeoff_page)
        self.pages.addWidget(self.passengers_board_page)
        self.pages.addWidget(self.passengers_disembark_page)
        self.pages.addWidget(self.assign_pilot_page)
        self.pages.addWidget(self.recycle_crew_page)
        self.pages.addWidget(self.retire_flight_page)
        self.pages.addWidget(self.remove_passenger_role_page)
        self.pages.addWidget(self.remove_pilot_role_page)
        self.pages.addWidget(self.flights_in_the_air_page) # 19
        self.pages.addWidget(self.flights_on_the_ground_page)
        self.pages.addWidget(self.people_in_the_air_page)
        self.pages.addWidget(self.people_on_the_ground_page)
        self.pages.addWidget(self.route_summary_page)
        self.pages.addWidget(self.alternative_airports_page) # 24
        self.pages.addWidget(self.simulation_cycle_page)
    

        print("To be implemented ...")

if __name__ == '__main__':
    # You need one (and only one) QApplication instance per application.
    # Pass in sys.argv to allow command line arguments for your app.
    # If you know you won't use command line arguments QApplication([]) works too.
    app = QApplication(sys.argv)

    # Create a Qt widget, which will be our window.
    window = MainWindow()
    window.show()  # IMPORTANT!!!!! Windows are hidden by default.

    # Start the event loop.
    app.exec()

    # Your application won't reach here until you exit and the event
    # loop has stopped.