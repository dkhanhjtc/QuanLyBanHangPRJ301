package model;

import java.io.Serializable;
import java.sql.Timestamp;

public class User implements Serializable {
    private static final long serialVersionUID = 1L;

    private int id;
    private String loginCode;
    private String phone;
    private String fullName;
    private String password;
    private String role; // 'ADMIN', 'MANAGER', 'STAFF'
    private boolean isActive;
    private Timestamp createdAt;

    public User() {
    }

    public User(int id, String loginCode, String fullName, String password, String role, boolean isActive, Timestamp createdAt) {
        this.id = id;
        this.loginCode = loginCode;
        this.fullName = fullName;
        this.password = password;
        this.role = role;
        this.isActive = isActive;
        this.createdAt = createdAt;
    }

    public User(int id, String loginCode, String phone, String fullName, String password, String role, boolean isActive, Timestamp createdAt) {
        this.id = id;
        this.loginCode = loginCode;
        this.phone = phone;
        this.fullName = fullName;
        this.password = password;
        this.role = role;
        this.isActive = isActive;
        this.createdAt = createdAt;
    }

    public int getId() {
        return id;
    }

    public void setId(int id) {
        this.id = id;
    }

    public String getLoginCode() {
        return loginCode;
    }

    public void setLoginCode(String loginCode) {
        this.loginCode = loginCode;
    }

    public String getPhone() {
        return phone;
    }

    public void setPhone(String phone) {
        this.phone = phone;
    }

    public String getFullName() {
        return fullName;
    }

    public void setFullName(String fullName) {
        this.fullName = fullName;
    }

    public String getPassword() {
        return password;
    }

    public void setPassword(String password) {
        this.password = password;
    }

    public String getRole() {
        return role;
    }

    public void setRole(String role) {
        this.role = role;
    }

    public boolean isIsActive() {
        return isActive;
    }

    public boolean getIsActive() {
        return isActive;
    }

    public void setIsActive(boolean isActive) {
        this.isActive = isActive;
    }

    public Timestamp getCreatedAt() {
        return createdAt;
    }

    public void setCreatedAt(Timestamp createdAt) {
        this.createdAt = createdAt;
    }

    @Override
    public String toString() {
        return "User{" +
                "id=" + id +
                ", loginCode='" + loginCode + '\'' +
                ", fullName='" + fullName + '\'' +
                ", role='" + role + '\'' +
                ", isActive=" + isActive +
                '}';
    }
}

