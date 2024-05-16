import pymysql.cursors

class MySQLConnection:
    def __init__(self):
        self.host = '127.0.0.1'
        self.username = 'root'
        self.password = 'Pulcha12!'
        self.database = 'flight_management'
        self.conn = None

    def __enter__(self):
        self.conn = pymysql.connect(
            host=self.host,
            user=self.username,
            password=self.password,
            db=self.database,
            charset='utf8mb4',
            cursorclass=pymysql.cursors.DictCursor
        )
        return self.conn

    def __exit__(self, exc_type, exc_val, exc_tb):
        if self.conn:
            self.conn.close()

