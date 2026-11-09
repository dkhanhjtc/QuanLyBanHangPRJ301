import dal.UserDAO;
import model.User;

public class Test {
    public static void main(String[] args) {
        UserDAO dao = new UserDAO();

        String[][] testCases = {
            {"090 123 4123", "123456", "ADMIN"},
            {"AN-SA-001", "123456", "ADMIN"},
            {"090 987 6543", "123456", "MANAGER"},
            {"AN-QL-001", "123456", "MANAGER"},
            {"090 555 1122", "123456", "STAFF"},
            {"AN-NV-002", "123456", "STAFF"},
            {"090 333 7788", "123456", "STAFF"},
            {"AN-NV-003", "123456", "STAFF"}
        };

        boolean allPassed = true;
        for (String[] tc : testCases) {
            User u = dao.login(tc[0], tc[1]);
            if (u != null && tc[2].equals(u.getRole())) {
                System.out.println("[PASS] " + tc[0] + " -> " + u.getFullName() + " (" + u.getRole() + ")");
            } else {
                System.out.println("[FAIL] " + tc[0]);
                allPassed = false;
            }
        }

        if (allPassed) {
            System.out.println(">>> TAT CA 3 TAI KHOAN HARDCODE DANG NHAP HOAN HAO! <<<");
        }
    }
}
