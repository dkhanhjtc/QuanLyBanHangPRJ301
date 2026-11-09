package controller;

import dal.ActivityLogDAO;
import model.ActivityLog;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.util.List;

@WebServlet(name = "ActivityLogServlet", urlPatterns = {"/activity-log"})
public class ActivityLogServlet extends HttpServlet {

    private final ActivityLogDAO logDAO = new ActivityLogDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        List<ActivityLog> logs = logDAO.getAllLogs();
        request.setAttribute("logs", logs);

        request.getRequestDispatcher("/views/activity_log.jsp").forward(request, response);
    }
}

