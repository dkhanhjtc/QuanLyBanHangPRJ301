package dal;

import java.sql.Connection;
import java.sql.DriverManager;

public class DBContext {
    protected Connection connection;

    // Các tham số cấu hình kết nối SQL Server
    private final String serverName = "localhost";
    private final String portNumber = "1433";
    private final String dbName = "QuanLyBanHangThoiTrang";
    private final String userID = "sa";
    private final String password = "123";

    public DBContext() {
        try {
            this.connection = getConnection();
        } catch (Exception e) {
            // Log thông báo cấu hình kết nối mà không làm dừng ứng dụng
            System.err.println("DBContext init info: " + e.getMessage());
        }
    }

    /**
     * Lấy kết nối JDBC tới cơ sở dữ liệu SQL Server KiotFlow_DB
     * @return Connection đối tượng kết nối đang mở
     * @throws Exception nếu không tìm thấy driver hoặc sai thông tin xác thực
     */
    public Connection getConnection() throws Exception {
        String url = "jdbc:sqlserver://" + serverName + ":" + portNumber 
                + ";databaseName=" + dbName 
                + ";encrypt=true;trustServerCertificate=true";
        Class.forName("com.microsoft.sqlserver.jdbc.SQLServerDriver");
        return DriverManager.getConnection(url, userID, password);
    }
}

