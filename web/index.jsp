<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%
  // Forward to manager dashboard by default or login page
  response.sendRedirect(request.getContextPath() + "/views/dashboard.jsp");
%>

