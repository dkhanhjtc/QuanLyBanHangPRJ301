package model;

import java.io.Serializable;
import java.sql.Timestamp;
import java.text.SimpleDateFormat;

public class StocktakeAssignment implements Serializable {
    private static final long serialVersionUID = 1L;

    private int assignmentId;
    private int stocktakeId;
    private String stocktakeCode;
    private int staffId;
    private String staffName;
    private int categoryId;
    private String categoryName;
    private Timestamp assignedDate;
    private Timestamp deadline;
    private String status; // 'PENDING', 'SUBMITTED', 'REJECTED', 'APPROVED'

    public StocktakeAssignment() {
        this.status = "PENDING";
    }

    public StocktakeAssignment(int assignmentId, int stocktakeId, int staffId, int categoryId, Timestamp assignedDate, Timestamp deadline, String status) {
        this.assignmentId = assignmentId;
        this.stocktakeId = stocktakeId;
        this.staffId = staffId;
        this.categoryId = categoryId;
        this.assignedDate = assignedDate;
        this.deadline = deadline;
        this.status = status;
    }

    public StocktakeAssignment(int assignmentId, int stocktakeId, String stocktakeCode, int staffId, String staffName, int categoryId, String categoryName, Timestamp assignedDate, Timestamp deadline, String status) {
        this.assignmentId = assignmentId;
        this.stocktakeId = stocktakeId;
        this.stocktakeCode = stocktakeCode;
        this.staffId = staffId;
        this.staffName = staffName;
        this.categoryId = categoryId;
        this.categoryName = categoryName;
        this.assignedDate = assignedDate;
        this.deadline = deadline;
        this.status = status;
    }

    public int getAssignmentId() {
        return assignmentId;
    }

    public void setAssignmentId(int assignmentId) {
        this.assignmentId = assignmentId;
    }

    public int getStocktakeId() {
        return stocktakeId;
    }

    public void setStocktakeId(int stocktakeId) {
        this.stocktakeId = stocktakeId;
    }

    public String getStocktakeCode() {
        return stocktakeCode;
    }

    public void setStocktakeCode(String stocktakeCode) {
        this.stocktakeCode = stocktakeCode;
    }

    public int getStaffId() {
        return staffId;
    }

    public void setStaffId(int staffId) {
        this.staffId = staffId;
    }

    public String getStaffName() {
        return staffName;
    }

    public void setStaffName(String staffName) {
        this.staffName = staffName;
    }

    public int getCategoryId() {
        return categoryId;
    }

    public void setCategoryId(int categoryId) {
        this.categoryId = categoryId;
    }

    public String getCategoryName() {
        return categoryName;
    }

    public void setCategoryName(String categoryName) {
        this.categoryName = categoryName;
    }

    public Timestamp getAssignedDate() {
        return assignedDate;
    }

    public void setAssignedDate(Timestamp assignedDate) {
        this.assignedDate = assignedDate;
    }

    public Timestamp getDeadline() {
        return deadline;
    }

    public void setDeadline(Timestamp deadline) {
        this.deadline = deadline;
    }

    public String getStatus() {
        return status;
    }

    public void setStatus(String status) {
        this.status = status;
    }

    public String getFormattedDeadline() {
        if (deadline != null) {
            return new SimpleDateFormat("dd/MM/yyyy HH:mm").format(deadline);
        }
        return "Không giới hạn";
    }
}

