"""Database connection and operations."""

from motor.motor_asyncio import AsyncIOMotorClient

from backend.config import settings


class DatabaseManager:
    """Manages MongoDB connection."""

    client: AsyncIOMotorClient | None = None
    db = None

    @classmethod
    async def connect(cls):
        """Connect to MongoDB."""
        cls.client = AsyncIOMotorClient(settings.mongodb_url)
        cls.db = cls.client[settings.mongodb_db_name]
        print(f"Connected to MongoDB: {settings.mongodb_db_name}")

    @classmethod
    async def disconnect(cls):
        """Disconnect from MongoDB."""
        if cls.client:
            cls.client.close()
            print("Disconnected from MongoDB")

    @classmethod
    def get_database(cls):
        """Get database instance."""
        return cls.db


# Database instance
db_manager = DatabaseManager()
