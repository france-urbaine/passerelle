CREATE TRIGGER trigger_office_users_changes
  AFTER INSERT OR DELETE ON office_users
  FOR EACH ROW EXECUTE FUNCTION trigger_office_users_changes();